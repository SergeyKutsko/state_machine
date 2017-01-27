# The main StateMachine module
require 'set'
require_relative './state_machine/event.rb'
require_relative './state_machine/state.rb'
require 'graphviz'

# Main gem module
module StateMachine
  # define custom exceptions
  class DoubleInitialStateError < StandardError
    def initialize(msg = "You can't define init state twice"); super; end
  end

  class TransitionError < StandardError
    def initialize(msg = "No such transition defined"); super; end
  end

  class NoInitialStateError < StandardError
    def initialize(msg = "No intial state defined"); super; end
  end

  class UnknownOptionTypeError < StandardError
    def initialize(msg = "Option class should be Symbol or Proc"); super; end
  end

  class UndefinedStateError < ArgumentError
    def initialize(state_name)
      super "State #{state_name} is not defined"
    end
  end

  def self.included(base)
    #extend class on module Include
    base.extend(ClassMethods)
  end

  def initialize(state = nil)
    #setup instance varibles
    self.state_transition_table = self.class.state_transition_table
    self.current_state = self.class.current_state

    #fire exception if no initial state defined
    raise NoInitialStateError.new if current_state.nil? && state.nil?
    #set initial via instance initialize if not set via DSL
    if current_state.nil? && state
      # TODO research this more
      self.current_state = State.new(name.to_sym, initial: true)
    elsif state
      #fire exeption if define intial state twice via DSL and Instance
      raise DoubleInitialStateError.new
    end
  end

  attr_accessor :state_transition_table, :current_state

  module ClassMethods
    attr_reader :events, :states
    attr_accessor :current_state, :state_transition_table

    def event(name, &block)
      # Collect all defined events into Set
      @events ||= Set.new
      event = StateMachine::Event.new(name.to_sym, self, &block)
      events.add event
      # Define instance method to fire event
      define_method "#{name}!" do
        # Check if transition possible for current state
        key = [event, current_state]
        if transition = state_transition_table[key]
          # Run when Guards if exists
          callback_exec_flow(transition) if execute_callback(transition.when)
        else
          # Fire exception if no transition possible for current state
          raise TransitionError.new
        end
      end
      # Check if the event can be triggered (e.g., by calling #can_walk?).
      define_method "can_#{name}?" do
        event = StateMachine::Event.new(name.to_sym, self.class)
        if self.class.events.include?(event)
          state_transition_table[[event, current_state]] ? true : false
        else
          false
        end
      end
    end

    def state(name, options = {})
      @states ||= Set.new
      state = State.new(name.to_sym, options)
      states.add state
      # Define initial state via DSL options
      if options[:initial]
        if current_state.nil?
          self.current_state = state
        else
          # Fire exeption if define intial state twice via DSL
          raise DoubleInitialStateError.new
        end
      end
      # Define method to check if current state
      define_method "#{name}?" do
        current_state.name == state.name
      end
    end
  end

  private

  def callback_exec_flow(transition)
    # Run state's callback leave_state
    execute_callback current_state.options[:leave_state]
    # Run before transition callback
    execute_callback transition.before
    # Change a current state
    self.current_state = transition.to
    # Run after transition callback
    execute_callback transition.after
    # Run state's callback enter_state
    execute_callback current_state.options[:enter_state]
  end

  def execute_callback(callback)
    case callback
    when Proc
      instance_exec &callback
    when Symbol
      send(callback)
    when NilClass
      # If no when clause defined
      true
    else
      # Raise an error when unknow type of when clause
      raise UnknownOptionTypeError.new
    end
  end

  # Generates a diagram for the state machine
  # showing states and possible transitions
  def self.draw(klass)
    GraphViz.new(:G, type: :digraph) do |g|
      klass.state_transition_table.map do |k, v|
        node1 = g.add_nodes(k[1].name.to_s.capitalize)
        node2 = g.add_nodes(v.to.to_s.capitalize)
        g.add_edges(node1, node2, label: k[0].name.to_s.capitalize)
      end
    end.output(png: "#{klass}.png")
    true
  end
end

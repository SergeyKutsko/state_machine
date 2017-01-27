# The main StateMachine module
require 'set'
require_relative './state_machine/state.rb'
require_relative './state_machine/errors.rb'
require_relative './state_machine/event.rb'
require 'graphviz'

# Main gem module
module StateMachine
  include Errors

  class << self
    def included(base)
      # Extend class on module Include
      base.extend(ClassMethods)
    end

    # Generates a diagram for the state machine
    # showing states and possible transitions
    def draw(klass)
      GraphViz.new(:G, type: :digraph) do |g|
        klass.state_transition_table.map do |k, v|
          g.add_edges(g.add_nodes(k[1].to_s),
                      g.add_nodes(v[:to].to_s),
                      label: k[0].name)
        end
      end.output(png: "#{klass}.png")
      true
    end
  end

  def initialize(state = nil)
    # Setup instance varibles
    self.state_transition_table = self.class.state_transition_table
    self.current_state = self.class.current_state
    setup_initial_state(state)
    super()
  end

  attr_accessor :state_transition_table, :current_state
  # Module contains methods that will extend class
  module ClassMethods
    attr_reader :events, :states
    attr_accessor :current_state, :state_transition_table

    def event(name, &block)
      # Collect all defined events into Set
      @events ||= Set.new
      event = StateMachine::Event.new(name.to_sym, self, &block)
      events.add event
      define_event_method(event, name)
      define_event_query_method(name)
    end

    def state(name, options = {})
      @states ||= Set.new
      state = State.new(name.to_sym, options)
      states.add state
      # Define initial state via DSL options
      if options[:initial]
        # Fire exeption if define intial state twice via DSL
        raise Errors::DoubleInitialStateError unless current_state.nil?
        self.current_state = state
      end
      # Define method to check if current state
      define_method "#{name}?" do
        current_state.name == state.name
      end
    end

    private

    # Define instance method to fire event
    def define_event_method(event, name)
      define_method "#{name}!" do
        # Check if transition possible for current state
        key = [event, current_state]
        transition = state_transition_table[key]
        # Fire exception if no transition possible for current state
        raise Errors::TransitionError unless transition
        # Run when Guards if exists
        callback_exec_flow(transition) if execute_callback(transition[:when])
      end
    end

    # Check if the event can be triggered (e.g., by calling #can_walk?).
    def define_event_query_method(name)
      define_method "can_#{name}?" do
        event = StateMachine::Event.new(name.to_sym, self.class)
        if self.class.events.include?(event)
          state_transition_table[[event, current_state]] ? true : false
        else
          false
        end
      end
    end
  end

  private

  def setup_initial_state(state)
    # Fire exception if no initial state defined
    raise NoInitialStateError if current_state.nil? && state.nil?
    # Set initial via instance initialize if not set via DSL
    if current_state.nil? && state
      # TODO: RESEARCH THIS MORE
      self.current_state = State.new(name.to_sym, initial: true)
    elsif state
      # Fire exeption if define intial state twice via DSL and Instance
      raise DoubleInitialStateError
    end
  end

  def callback_exec_flow(transition)
    # Run state's callback leave_state
    execute_callback current_state.options[:leave_state]
    # Run before transition callback
    execute_callback transition[:before]
    # Change a current state
    self.current_state = transition[:to]
    # Run after transition callback
    execute_callback transition[:after]
    # Run state's callback enter_state
    execute_callback current_state.options[:enter_state]
  end

  def execute_callback(callback)
    case callback
    when Proc
      instance_exec(&callback)
    when Symbol
      send(callback)
    when NilClass
      # If no when clause defined
      true
    else
      # Raise an error when unknow type of when clause
      raise UnknownOptionTypeError
    end
  end
end

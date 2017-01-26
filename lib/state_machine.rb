# The main StateMachine module
require 'set'
require 'state_machine/event'
require 'state_machine/state'
require 'graphviz'

module StateMachine
  #define custom exceptions
  class DoubleInitialStateError < StandardError
    def initialize(msg="You can't define init state twice"); super; end
  end

  class TransitionError < StandardError
    def initialize(msg="No such transition defined"); super; end
  end

  class NoInitialStateError < StandardError
    def initialize(msg="No intial state defined"); super; end
  end

  class UndefinedStateError < StandardError
    def initialize(state_name)
      msg="State #{state_name} is not defined"
      super msg
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
      self.current_state = State.new(name.to_sym)
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
      #collect all defined events into Set
      @events ||= Set.new
      event = StateMachine::Event.new(name.to_sym, self, &block)
      events.add event
      #define instance method to fire event
      define_method "#{name}!" do
        #check if transition possible for current state
        key = [event, current_state]
        if transition = state_transition_table[key]
          #run when Guards if exists
          if transition.when.class == Proc
            self.current_state = transition.to if transition.when.call
          elsif transition.when.class == Symbol
            self.current_state = transition.to if send(transition.when)
          elsif transition.when.nil?
            self.current_state = transition.to
          end

        else
          #fire exception if no transition possible for current state
          raise TransitionError.new
        end
      end
    end

    def state(name, options = {})
      @states ||= Set.new
      state = State.new(name.to_sym)
      states.add state
      #define initial state via DSL options
      if options[:initial]
        if current_state.nil?
          self.current_state = state
        else
          #fire exeption if define intial state twice via DSL
          raise DoubleInitialStateError.new
        end
      end

      #define method to check if current state
      define_method "#{name}?" do
        current_state.name == state.name
      end
    end
  end


  def method_missing method, *args, &block
    return super method, *args, &block unless method.to_s =~ /can_(\w+)?/
    #Check if the event can be triggered (e.g., by calling #can_walk?).
    self.class.send(:define_method, method) do
      event = StateMachine::Event.new($1.to_s.to_sym, self)
      if self.class.events.include?(event)
        !!state_transition_table[[event, current_state]]
      else
        false
      end
    end

    self.send method, *args, &block
  end

  #generates a diagram for the state machine showing states and possible transitions
  def self.draw(klass)
    GraphViz::new( :G, :type => :digraph ) do |g|
      klass.state_transition_table.map do |k, v|
        node1 = g.add_nodes( k[1].name.to_s.capitalize )
        node2 = g.add_nodes( v.to.to_s.capitalize )
        g.add_edges( node1, node2, label: k[0].name.to_s.capitalize)
      end
    end.output( :png => "#{klass}.png" )
    true
  end

end
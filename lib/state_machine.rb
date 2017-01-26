# The main StateMachine module
require 'set'
require 'state_machine/event'
require 'graphviz'

module StateMachine
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
    base.extend(ClassMethods)
  end

  def initialize(state = nil)
    self.state_transition_table = self.class.state_transition_table
    self.current_state = self.class.current_state

    raise NoInitialStateError.new if current_state.nil? && state.nil?
    if current_state.nil? && state
      self.current_state = state
    elsif state
      raise DoubleInitialStateError.new
    end
  end

  attr_accessor :state_transition_table, :current_state

  module ClassMethods
    attr_reader :events, :states
    attr_accessor :current_state, :state_transition_table

    def event(name, &block)
      @events ||= Set.new
      event = StateMachine::Event.new(name, self, &block)
      events.add event

      define_method "#{name}!" do
        key = [event.name, current_state]
        if state = state_transition_table[key]
          self.current_state = state
        else
          raise TransitionError.new
        end
      end
    end

    def state(name, options = {}, &block)
      @states ||= Set.new
      states.add name.to_sym

      if options[:initial]
        if current_state.nil?
          self.current_state = name.to_sym
        else
          raise DoubleInitialStateError.new
        end
      end

      define_method "#{name}?" do
        current_state.to_sym == name.to_sym
      end
    end
  end


  def method_missing method, *args, &block
    return super method, *args, &block unless method.to_s =~ /can_(\w+)?/
    self.class.send(:define_method, method) do
      self.class.events.include?(StateMachine::Event.new($1.to_sym, self))
    end

    self.send method, *args, &block
  end

  def self.draw(klass)
    GraphViz::new( :G, :type => :digraph ) do |g|
      nodes = klass.state_transition_table.map do |k, v|
        node1 = g.add_nodes( k[1].to_s.capitalize )
        node2 = g.add_nodes( v.to_s.capitalize )
        g.add_edges( node1, node2, label: k[0].to_s.capitalize)
      end
    end.output( :png => "#{klass}.png" )
    true
  end

end
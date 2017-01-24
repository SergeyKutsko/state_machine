# The main StateMachine module
require 'set'
require 'state_machine/event'

module StateMachine

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def event(name, &block)
      @events ||= Set.new
      events.add StateMachine::Event.new(name, &block)
    end

    private

    def events
      instance_variable_get(:@events)
    end

    def states
      instance_variable_get(:@states)
    end

    def state(name, options = {}, &block)
      @states ||= Set.new
      states.add name.to_sym
    end
  end


  def method_missing method, *args, &block
    return super method, *args, &block unless method.to_s =~ /can_(\w+)?/
    self.class.send(:define_method, method) do
      self.singleton_class.instance_variable_get(:@events).include?(StateMachine::Event.new($1.to_sym))
    end

    self.send method, *args, &block
  end

end
module StateMachine
  class Event
    attr_accessor :name
    def initialize(name, machine, &block)
      @name = name
      @machine = machine
      instance_eval(&block) if block_given?
    end

    def transitions(options = {})
      validate_transition_params(options)
      @machine.state_transition_table ||= Hash.new
      [options[:from]].flatten.each do |state|
        if not @machine.states.include?(state.to_sym)
          raise UndefinedStateError.new(state)
        elsif not @machine.states.include?(options[:to].to_sym)
          raise UndefinedStateError.new(options[:to])
        end
        @machine.state_transition_table[[@name.to_sym, state.to_sym]] = options[:to]
      end
    end

    def hash
      name.to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end

    private

    def validate_transition_params(options)
    end
  end
end
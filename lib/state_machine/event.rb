# Namespace
module StateMachine
  # Event class definition
  class Event
    attr_accessor :name
    def initialize(name, machine, &block)
      @name = name
      @machine = machine
      instance_eval(&block) if block_given?
    end

    def transitions(options = {})
      validate_transition_params(options)
      # Init state transition table on first transitions method call
      @machine.state_transition_table ||= {}
      # Add tarnsition to table
      [options[:from]].flatten.each do |state|
        @machine.state_transition_table[[self, find_state(state)]] =
          {
            to: find_state(options[:to]), when: options[:when],
            before: options[:before], after: options[:after]
          }
      end
    end

    def to_s
      name.to_s
    end

    def hash
      to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end

    private

    def find_state(name)
      state = states.find { |el| el == name }
      raise Errors::UndefinedStateError, name unless state
      state
    end

    def states
      @states ||= @machine.states.to_a
    end

    def valid_transition_keys
      @valid_transition_keys ||= %i(from to when before after)
    end

    def validate_transition_params(options)
      return if (options.keys - valid_transition_keys).empty?
      raise ArgumentError,
            "Transition args must be #{valid_transition_keys.join(', ')}"
    end
  end
end

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
      #init state transition table on first transitions method call
      @machine.state_transition_table ||= Hash.new
      #add tarnsition to table
      [options[:from]].flatten.each do |state|
        @machine.state_transition_table[[self, find_state(state)]] =
          ::OpenStruct.new to: find_state(options[:to]),
                           when: options[:when],
                           before: options[:before],
                           after: options[:after]
      end
    end

    def hash
      name.to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end

    private

    def find_state(name)
      if state = states.find{ |el| el == name }
        state
      else
        raise UndefinedStateError.new(name)
      end
    end

    def states
      @states ||= @machine.states.to_a
    end

    def valid_transition_options_keys
      @valid_transition_options_keys ||= %i[from to when before after]
    end

    def validate_transition_params(options)
      return if (options.keys - valid_transition_options_keys).empty?
      raise ArgumentError,
            "Transition args must be #{valid_transition_options_keys.join(", ")}"
    end
  end
end

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
        from_state = State.new(state.to_sym)
        to_state = State.new(options[:to].to_sym)
        if not @machine.states.include?(from_state)
          raise UndefinedStateError.new(state)
        elsif not @machine.states.include?(to_state)
          raise UndefinedStateError.new(options[:to])
        end
        @machine.state_transition_table[[self, from_state]] =
          ::OpenStruct.new(event: self, to: to_state, when: options[:when])
      end
    end

    def hash
      name.to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end

    private

    def valid_transition_options_keys
      @valid_transition_options_keys ||= %i[from to when]
    end

    def validate_transition_params(options)
      unless (options.keys - valid_transition_options_keys).empty?
        raise ArgumentError, "Transition args must be #{valid_transition_options_keys.join(", ")}"
      end
    end
  end
end
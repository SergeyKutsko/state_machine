# Namespace
module StateMachine
  # State class definition
  class State
    attr_accessor :name, :options
    def initialize(name, options = {})
      validate_state_params(options)
      @options = options
      @name = name
    end

    def ==(other)
      to_s == other.to_s
    end

    def hash
      to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end

    def to_s
      name.to_s
    end

    def to_str
      to_s
    end

    private

    def valid_state_options_keys
      @valid_state_options_keys ||= %i(initial enter_state leave_state)
    end

    def validate_state_params(options)
      return if (options.keys - valid_state_options_keys).empty?
      raise ArgumentError,
            "Transition args must be #{valid_state_options_keys.join(', ')}"
    end
  end
end

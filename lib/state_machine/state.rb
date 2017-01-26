module StateMachine
  class State
    attr_accessor :name
    def initialize(name)
      @name = name
    end

    def hash
      name.to_s.hash
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

    def validate_state_params(options)
    end
  end
end
module StateMachine
  class Event
    attr_accessor :name
    def initialize(name, &block)
      @name = name
      instance_eval(&block) if block_given?
    end

    def transitions(options = {})

    end

    def hash
      name.to_s.hash
    end

    def eql?(other)
      hash == other.hash
    end
  end
end
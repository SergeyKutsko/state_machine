# Namespace
module StateMachine
  # Define custom exceptions here
  module Errors
    # Raises when try init initial state twice
    class DoubleInitialStateError < StandardError
      def initialize(msg = "You can't define init state twice")
        super
      end
    end
    # Raises when no transition possible for current state
    class TransitionError < StandardError
      def initialize(msg = 'No such transition defined')
        super
      end
    end
    # Raises when no defined initial state
    class NoInitialStateError < StandardError
      def initialize(msg = 'No intial state defined')
        super
      end
    end
    # Raises when wrong option type
    class UnknownOptionTypeError < StandardError
      def initialize(msg = 'Option class should be Symbol or Proc')
        super
      end
    end
    # Raises when undefined state used in transition
    class UndefinedStateError < ArgumentError
      def initialize(state_name)
        super "State #{state_name} is not defined"
      end
    end
  end
end

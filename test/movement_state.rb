require 'state_machine'
class MovementState
  include StateMachine

  state :standing, initial: true
  state :walking
  state :running

  event :walk do
    transitions from: :standing, to: :walking
  end

  event :run do
    transitions from: [:standing, :walking], to: :running
  end

  event :hold do
    transitions from: [:walking, :running], to: :standing
  end
end
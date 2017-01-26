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
    transitions from: [:standing, :walking], to: :running, when: :run_possible?
  end

  event :hold do
    transitions from: [:walking, :running], to: :standing, when: lambda { false }
  end

  def run_possible?
    true
  end
end
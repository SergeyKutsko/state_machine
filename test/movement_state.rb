require 'state_machine'
class MovementState
  include StateMachine

  state :standing, initial: true, leave_state: :leave_standing_state
  state :walking,  enter_state: :enter_walking_state
  state :running

  event :walk do
    transitions from: :standing, to: :walking
  end

  event :run do
    transitions(from: [:standing, :walking], to: :running, when: :run_possible?)
  end

  event :hold do
    transitions from: [:walking, :running], to: :standing, when: lambda { false }
  end

  def run_possible?
    true
  end

  def leave_standing_state
    #DO something
    puts 'leave_standing_state'
    self
  end

  def enter_walking_state
    #DO something
    puts 'enter_walking_state'
    self
  end
end
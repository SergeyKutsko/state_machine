require 'state_machine'
# Class for testing purpose and example
class MovementState
  include StateMachine

  state :standing, initial: true, leave_state: :leave_standing_state
  state :walking,  enter_state: :enter_walking_state
  state :running

  event :walk do
    transitions from: :standing,
                to: :walking
  end

  event :run do
    transitions from: [:standing, :walking],
                to: :running,
                when: :symbol_run_possible?,
                before: :before_run_transition,
                after: -> { run_possible? }
  end

  event :hold do
    transitions from: [:walking, :running],
                to: :standing,
                when: -> { run_possible? }
  end

  def before_run_transition
    true
  end

  def symbol_run_possible?
    true
  end

  def run_possible?
    false
  end

  def leave_standing_state
    # DO something
    self
  end

  def enter_walking_state
    # DO something
    self
  end
end

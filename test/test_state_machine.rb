require 'minitest/autorun'
require 'state_machine'
require 'test_helper'

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

class StateMachineTest < Minitest::Test

  def setup
    @object = MovementState.new
  end

  def test_double_initial_state_error
    assert_raises StateMachine::DoubleInitialStateError do
      MovementState.new(:walking)
    end
  end

  def test_double_initial_state_error_2
    assert_raises StateMachine::DoubleInitialStateError do
      self.class.const_set :B, Class.new {
        include StateMachine
        state :standing, initial: true
        state :walking, initial: true
      }
    end
  end

  def test_transition_error
    assert_raises StateMachine::TransitionError do
      @object.hold!
    end
  end

  def test_no_initial_dtate_error
    self.class.const_set :B, Class.new {
      include StateMachine
      state :standing
    }
    assert_raises StateMachine::NoInitialStateError do
      B.new
    end

    self.class.send :remove_const, :B
  end

  def test_undefined_state_transition_from_error
    assert_raises StateMachine::UndefinedStateError do
      self.class.const_set :B, Class.new {
        include StateMachine
        state :standing, initial: true
        state :walking

      event :hold do
        transitions from: :running, to: :standing
      end
      }
    end
  end

  def test_undefined_state_transition_to_error
    assert_raises StateMachine::UndefinedStateError do
      self.class.const_set :B, Class.new {
        include StateMachine
        state :standing, initial: true
        state :walking

      event :run do
        transitions from: :standing, to: :running
      end
      }
    end
  end

  def test_state_transition_to_next_state
    assert_equal false, @object.walking?
    @object.walk!
    assert_equal true, @object.walking?
    @object.run!
    assert_equal true, @object.running?
  end


  def test_module_name
    assert_equal "StateMachine",
      StateMachine.to_s
  end

  def test_state_definition
    assert_equal true,
      @object.class.respond_to?(:state)
  end

  def test_event_definition
    assert_equal true,
      @object.class.respond_to?(:event)
  end

  def test_event_querying_when_no_event_defined
    assert_equal false,
      @object.can_jump?
  end

  def test_event_querying_when_event_defined_walk
    assert_equal true,
      @object.can_walk?
  end

  def test_event_querying_when_event_defined_run
    assert_equal true,
      @object.can_run?
  end

  def test_event_querying_when_event_defined_hold
    assert_equal true,
      @object.can_hold?
  end
end
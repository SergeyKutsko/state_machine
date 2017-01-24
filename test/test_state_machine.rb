require 'minitest/autorun'
require 'state_machine'
require 'test_helper'

class StateMachineTest < Minitest::Test

  def setup
    @klass = Class.new
    class << @klass
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
  end

  def test_module_name
    assert_equal "StateMachine",
      StateMachine.to_s
  end

  def test_state_definition_public
    assert_equal false,
      @klass.singleton_class.respond_to?(:state)
  end

  def test_event_definition_public
    assert_equal true,
      @klass.singleton_class.respond_to?(:event)
  end

  def test_state_definition_private
    assert_equal true,
      @klass.singleton_class.respond_to?(:state, true)
  end

  def test_event_querying_when_no_event_defined
    assert_equal false,
      @klass.can_jump?
  end

  def test_event_querying_when_event_defined
    assert_equal true,
      @klass.can_walk?
  end

  def test_events
    @klass.singleton_class.send :events
  end
end
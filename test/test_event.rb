require 'minitest/autorun'
require_relative './test_helper'

# Test Event class
class EventTest < Minitest::Test
  def setup
    @object = self.class.const_set :B, Class.new {
      include StateMachine
      state :standing, initial: true
      state :walking

      event :walk do
        transitions from: :standing, to: :walking
      end
    }
  end

  def test_event_name
    assert_equal :walk, @object.events.first.name
  end
end

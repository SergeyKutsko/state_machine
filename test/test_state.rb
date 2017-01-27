require 'minitest/autorun'
require_relative './test_helper'

# Test Event class
class StateTest < Minitest::Test
  def setup
    @object = self.class.const_set :B, Class.new {
      include StateMachine
      state :standing, initial: true
    }
  end

  def test_event_name
    assert_equal :standing, @object.states.first.name
  end
end

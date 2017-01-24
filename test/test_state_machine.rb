require 'minitest/autorun'
require 'state_machine'

class StateMachineTest < Minitest::Test
  def test_module_name
    assert_equal "StateMachine",
      StateMachine.to_s
  end
end
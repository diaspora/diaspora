require './test/test_helper'

class SupportTest < Test::Unit::TestCase
  include Mongo

  def test_command_response_succeeds
    assert Support.ok?('ok' => 1)
    assert Support.ok?('ok' => 1.0)
    assert Support.ok?('ok' => true)
  end

  def test_command_response_fails
    assert !Support.ok?('ok' => 0)
    assert !Support.ok?('ok' => 0.0)
    assert !Support.ok?('ok' => 0.0)
    assert !Support.ok?('ok' => 'str')
    assert !Support.ok?('ok' => false)
  end
end

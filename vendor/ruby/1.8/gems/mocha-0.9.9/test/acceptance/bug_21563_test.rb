require File.expand_path('../acceptance_test_helper', __FILE__)
require 'mocha'

class Bug21563Test < Test::Unit::TestCase
  
  include AcceptanceTest
  
  def setup
    setup_acceptance_test
  end
  
  def teardown
    teardown_acceptance_test
  end
  
  def test_should_allow_stubbing_of_verified_method
    test_result = run_as_test do
      object = Object.new
      object.stubs(:verified?).returns(false)
      assert !object.verified?
    end
    assert_passed(test_result)
  end
  
end

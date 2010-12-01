require File.expand_path('../../test_helper', __FILE__)

require 'mocha/single_yield'

class SingleYieldTest < Test::Unit::TestCase
  
  include Mocha

  def test_should_provide_parameters_for_single_yield_in_single_invocation
    parameter_group = SingleYield.new(1, 2, 3)
    parameter_groups = []
    parameter_group.each do |parameters|
      parameter_groups << parameters
    end
    assert_equal [[1, 2, 3]], parameter_groups
  end
  
end

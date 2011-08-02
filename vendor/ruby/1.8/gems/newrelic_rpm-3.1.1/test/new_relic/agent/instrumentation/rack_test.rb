require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper'))
require 'new_relic/agent/instrumentation/rack'

class MinimalRackApp
  def initialize(return_value)
    @return_value = return_value
  end

  def call(env)
    @return_value
  end

  include NewRelic::Agent::Instrumentation::Rack
end

class NewRelic::Agent::Instrumentation::RackTest < Test::Unit::TestCase

  def test_basic_rack_app
    # should return what we send in, even when instrumented
    x = MinimalRackApp.new([200, {}, ["whee"]])
    assert_equal [200, {}, ["whee"]], x.call({})
  end

  def test_basic_rack_app_404
    x = MinimalRackApp.new([404, {}, ["whee"]])
    assert_equal [404, {}, ["whee"]], x.call({})
  end

  def test_basic_rack_app_ignores_404
    NewRelic::Agent::Instrumentation::MetricFrame.expects(:abort_transaction!)
    x = MinimalRackApp.new([404, {}, ["whee"]])
    assert_equal [404, {}, ["whee"]], x.call({})
  end
end


require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
require 'new_relic/rack/browser_monitoring'
require 'new_relic/rack/developer_mode'
class NewRelic::Rack::AllTest < Test::Unit::TestCase
  # just here to load the files above

  def test_truth
    assert true
  end
end


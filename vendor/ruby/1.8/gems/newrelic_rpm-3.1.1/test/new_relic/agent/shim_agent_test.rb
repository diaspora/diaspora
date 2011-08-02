require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
module NewRelic
  module Agent
    class ShimAgentTest < Test::Unit::TestCase

      def setup
        super
        @agent = NewRelic::Agent::ShimAgent.new
      end

      def test_serialize
        assert_equal(nil, @agent.serialize, "should return nil when shut down")
      end

      def test_merge_data_from
        assert_equal(nil, @agent.merge_data_from(mock('metric data')))
      end
    end
  end
end

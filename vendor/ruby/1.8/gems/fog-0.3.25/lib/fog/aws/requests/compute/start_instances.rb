module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/start_stop_instances'

        # Start specified instance
        #
        # ==== Parameters
        # * instance_id<~Array> - Id of instance to start
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * TODO: fill in the blanks
        def start_instances(instance_id)
          params = AWS.indexed_param('InstanceId', instance_id)
          request({
            'Action'    => 'StartInstances',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::StartStopInstances.new
          }.merge!(params))
        end

      end

      class Mock

        def start_instances(instance_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

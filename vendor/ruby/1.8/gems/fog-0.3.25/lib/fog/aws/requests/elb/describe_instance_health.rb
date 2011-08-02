module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/describe_instance_health'

        # Get health status for one or more instances on an existing ELB
        #
        # ==== Parameters
        # * lb_name<~String> - Load balancer to check instances health on
        # * instance_ids<~Array> - Optional list of instance IDs to check
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'DescribeInstanceHealthResult'<~Hash>:
        #       * 'InstanceStates'<~Array> - array of hashes describing instance health
        #         * 'Description'<~String>
        #         * 'State'<~String>
        #         * 'InstanceId'<~String>
        #         * 'ReasonCode'<~String>
        def describe_instance_health(lb_name, instance_ids = [])
          params = AWS.indexed_param('Instances.member.%d.InstanceId', [*instance_ids])
          request({
            'Action'           => 'DescribeInstanceHealth',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::DescribeInstanceHealth.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_instance_health(lb_name, instance_ids = [])
          Fog::Mock.not_implemented
        end

      end

    end
  end
end

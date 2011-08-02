module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/register_instances_with_load_balancer'

        # Register an instance with an existing ELB
        #
        # ==== Parameters
        # * instance_ids<~Array> - List of instance IDs to associate with ELB
        # * lb_name<~String> - Load balancer to assign instances to
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'RegisterInstancesWithLoadBalancerResult'<~Hash>:
        #       * 'Instances'<~Array> - array of hashes describing instances currently enabled
        #         * 'InstanceId'<~String>
        def register_instances_with_load_balancer(instance_ids, lb_name)
          params = AWS.indexed_param('Instances.member.%d.InstanceId', [*instance_ids])
          request({
            'Action'           => 'RegisterInstancesWithLoadBalancer',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::RegisterInstancesWithLoadBalancer.new
          }.merge!(params))
        end

        alias :register_instances :register_instances_with_load_balancer

      end

      class Mock

        def register_instances_with_load_balancer(instance_ids, lb_name)
          Fog::Mock.not_implemented
        end

        alias :register_instances :register_instances_with_load_balancer

      end

    end
  end
end

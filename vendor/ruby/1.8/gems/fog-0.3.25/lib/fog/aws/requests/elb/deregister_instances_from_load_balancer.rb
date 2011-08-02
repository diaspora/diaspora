module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/deregister_instances_from_load_balancer'

        # Deregister an instance from an existing ELB
        #
        # ==== Parameters
        # * instance_ids<~Array> - List of instance IDs to remove from ELB
        # * lb_name<~String> - Load balancer to remove instances from
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'DeregisterInstancesFromLoadBalancerResult'<~Hash>:
        #       * 'Instances'<~Array> - array of hashes describing instances currently enabled
        #         * 'InstanceId'<~String>
        def deregister_instances_from_load_balancer(instance_ids, lb_name)
          params = AWS.indexed_param('Instances.member.%d.InstanceId', [*instance_ids])
          request({
            'Action'           => 'DeregisterInstancesFromLoadBalancer',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::DeregisterInstancesFromLoadBalancer.new
          }.merge!(params))
        end

        alias :deregister_instances :deregister_instances_from_load_balancer

      end

      class Mock

        def deregister_instances_from_load_balancer(instance_ids, lb_name)
          Fog::Mock.not_implemented
        end

        alias :deregister_instances :deregister_instances_from_load_balancer

      end

    end
  end
end

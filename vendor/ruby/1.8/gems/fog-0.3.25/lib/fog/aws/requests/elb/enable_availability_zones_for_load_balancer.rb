module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/enable_availability_zones_for_load_balancer'

        # Enable an availability zone for an existing ELB
        #
        # ==== Parameters
        # * availability_zones<~Array> - List of availability zones to enable on ELB
        # * lb_name<~String> - Load balancer to enable availability zones on
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'EnableAvailabilityZonesForLoadBalancerResult'<~Hash>:
        #       * 'AvailabilityZones'<~Array> - array of strings describing instances currently enabled
        def enable_availability_zones_for_load_balancer(availability_zones, lb_name)
          params = AWS.indexed_param('AvailabilityZones.member', [*availability_zones])
          request({
            'Action'           => 'EnableAvailabilityZonesForLoadBalancer',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::EnableAvailabilityZonesForLoadBalancer.new
          }.merge!(params))
        end

        alias :enable_zones :enable_availability_zones_for_load_balancer

      end

      class Mock

        def enable_availability_zones_for_load_balancer(availability_zones, lb_name)
          Fog::Mock.not_implemented
        end

        alias :enable_zones :enable_availability_zones_for_load_balancer

      end

    end
  end
end

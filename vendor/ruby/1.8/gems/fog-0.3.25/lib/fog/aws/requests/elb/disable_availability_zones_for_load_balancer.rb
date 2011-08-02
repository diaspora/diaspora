module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/disable_availability_zones_for_load_balancer'

        # Disable an availability zone for an existing ELB
        #
        # ==== Parameters
        # * availability_zones<~Array> - List of availability zones to disable on ELB
        # * lb_name<~String> - Load balancer to disable availability zones on
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'DisableAvailabilityZonesForLoadBalancerResult'<~Hash>:
        #       * 'AvailabilityZones'<~Array> - array of strings describing instances currently enabled
        def disable_availability_zones_for_load_balancer(availability_zones, lb_name)
          params = AWS.indexed_param('AvailabilityZones.member', [*availability_zones])
          request({
            'Action'           => 'DisableAvailabilityZonesForLoadBalancer',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::DisableAvailabilityZonesForLoadBalancer.new
          }.merge!(params))
        end

        alias :disable_zones :disable_availability_zones_for_load_balancer

      end

      class Mock

        def disable_availability_zones_for_load_balancer(availability_zones, lb_name)
          Fog::Mock.not_implemented
        end

        alias :disable_zones :disable_availability_zones_for_load_balancer

      end

    end
  end
end

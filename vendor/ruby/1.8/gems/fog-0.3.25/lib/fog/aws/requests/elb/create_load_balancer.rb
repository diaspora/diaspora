module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/create_load_balancer'

        # Create a new Elastic Load Balancer
        #
        # ==== Parameters
        # * availability_zones<~Array> - List of availability zones for the ELB
        # * lb_name<~String> - Name for the new ELB -- must be unique
        # * listeners<~Array> - Array of Hashes describing ELB listeners to assign to the ELB
        #   * 'Protocol'<~String> - Protocol to use. Either HTTP or TCP.
        #   * 'LoadBalancerPort'<~Integer> - The port that the ELB will listen to for outside traffic
        #   * 'InstancePort'<~Integer> - The port on the instance that the ELB will forward traffic to
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'CreateLoadBalancerResult'<~Hash>:
        #       * 'DNSName'<~String> - DNS name for the newly created ELB
        def create_load_balancer(availability_zones, lb_name, listeners)
          params = ELB.indexed_param('AvailabilityZones.member', [*availability_zones])

          listener_protocol = []
          listener_lb_port = []
          listener_instance_port = []
          listeners.each do |listener|
            listener_protocol.push(listener['Protocol'])
            listener_lb_port.push(listener['LoadBalancerPort'])
            listener_instance_port.push(listener['InstancePort'])
          end

          params.merge!(AWS.indexed_param('Listeners.member.%d.Protocol', listener_protocol))
          params.merge!(AWS.indexed_param('Listeners.member.%d.LoadBalancerPort', listener_lb_port))
          params.merge!(AWS.indexed_param('Listeners.member.%d.InstancePort', listener_instance_port))

          request({
            'Action'           => 'CreateLoadBalancer',
            'LoadBalancerName' => lb_name,
            :parser            => Fog::Parsers::AWS::ELB::CreateLoadBalancer.new
          }.merge!(params))
        end

      end

      class Mock

        def create_load_balancer(availability_zones, lb_name, listeners)
          Fog::Mock.not_implemented
        end

      end

    end
  end
end

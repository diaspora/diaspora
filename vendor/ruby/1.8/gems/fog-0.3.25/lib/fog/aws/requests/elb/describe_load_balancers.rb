module Fog
  module AWS
    class ELB
      class Real

        require 'fog/aws/parsers/elb/describe_load_balancers'

        # Describe all or specified load balancers
        #
        # ==== Parameters
        # * lb_name<~Array> - List of load balancer names to describe, defaults to all
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ResponseMetadata'<~Hash>:
        #       * 'RequestId'<~String> - Id of request
        #     * 'DescribeLoadBalancersResult'<~Hash>:
        #       * 'LoadBalancerDescriptions'<~Array>
        #         * 'LoadBalancerName'<~String> - name of load balancer
        #         * 'DNSName'<~String> - external DNS name of load balancer
        #         * 'CreatedTime'<~Time> - time load balancer was created
        #         * 'ListenerDescriptions'<~Array>
        #           * 'PolicyNames'<~Array> - list of policies enabled
        #           * 'Listener'<~Hash>:
        #             * 'InstancePort'<~Integer> - port on instance that requests are sent to
        #             * 'Protocol'<~String> - transport protocol used for routing in [TCP, HTTP]
        #             * 'LoadBalancerPort'<~Integer> - port that load balancer listens on for requests
        #         * 'HealthCheck'<~Hash>:
        #           * 'HealthyThreshold'<~Integer> - number of consecutive health probe successes required before moving the instance to the Healthy state
        #           * 'Timeout'<~Integer> - number of seconds after which no response means a failed health probe
        #           * 'Interval'<~Integer> - interval (in seconds) between health checks of an individual instance
        #           * 'UnhealthyThreshold'<~Integer> - number of consecutive health probe failures that move the instance to the unhealthy state
        #           * 'Target'<~String> - string describing protocol type, port and URL to check
        #         * 'Policies'<~Hash>:
        #           * 'LBCookieStickinessPolicies'<~Array> - list of Load Balancer Generated Cookie Stickiness policies for the LoadBalancer
        #           * 'AppCookieStickinessPolicies'<~Array> - list of Application Generated Cookie Stickiness policies for the LoadBalancer
        #         * 'AvailabilityZones'<~Array> - list of availability zones covered by this load balancer
        #         * 'Instances'<~Array> - list of instances that the load balancer balances between
        def describe_load_balancers(lb_name = [])
          params = AWS.indexed_param('LoadBalancerNames.member', [*lb_name])
          request({
            'Action'  => 'DescribeLoadBalancers',
            :parser   => Fog::Parsers::AWS::ELB::DescribeLoadBalancers.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_load_balancers(lb_name = [])
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

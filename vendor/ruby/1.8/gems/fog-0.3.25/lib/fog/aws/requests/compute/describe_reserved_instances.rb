module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_reserved_instances'

        # Describe all or specified reserved instances
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'reservedInstancesSet'<~Array>:
        #       * 'availabilityZone'<~String> - availability zone of the instance
        #       * 'duration'<~Integer> - duration of reservation, in seconds
        #       * 'fixedPrice'<~Float> - purchase price of reserved instance
        #       * 'instanceType'<~String> - type of instance
        #       * 'instanceCount'<~Integer> - number of reserved instances
        #       * 'productDescription'<~String> - reserved instance description
        #       * 'reservedInstancesId'<~String> - id of the instance
        #       * 'start'<~Time> - start time for reservation
        #       * 'state'<~String> - state of reserved instance purchase, in .[pending-payment, active, payment-failed, retired]
        #       * 'usagePrice"<~Float> - usage price of reserved instances, per hour
        def describe_reserved_instances(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_reserved_instances with #{filters.class} param is deprecated, use describe_reserved_instances('reserved-instances-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'reserved-instances-id' => [*filters]}
          end
          params = AWS.indexed_filters(filters)
          request({
            'Action'    => 'DescribeReservedInstances',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeReservedInstances.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_reserved_instances(filters = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

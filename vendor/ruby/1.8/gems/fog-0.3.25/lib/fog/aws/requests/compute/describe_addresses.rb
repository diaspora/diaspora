module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_addresses'

        # Describe all or specified IP addresses.
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'addressesSet'<~Array>:
        #       * 'instanceId'<~String> - instance for ip address
        #       * 'publicIp'<~String> - ip address for instance
        def describe_addresses(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_addresses with #{filters.class} param is deprecated, use describe_addresses('public-ip' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'public-ip' => [*filters]}
          end
          params = AWS.indexed_filters(filters)
          request({
            'Action'    => 'DescribeAddresses',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeAddresses.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_addresses(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_addresses with #{filters.class} param is deprecated, use describe_addresses('public-ip' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'public-ip' => [*filters]}
          end

          response = Excon::Response.new

          addresses_set = @data[:addresses].values

          aliases = {'public-ip' => 'publicIp', 'instance-id' => 'instanceId'}
          for filter_key, filter_value in filters
            aliased_key = aliases[filter_key]
            addresses_set = addresses_set.reject{|address| ![*filter_value].include?(address[aliased_key])}
          end

          response.status = 200
          response.body = {
            'requestId'     => Fog::AWS::Mock.request_id,
            'addressesSet'  => addresses_set
          }
          response
        end

      end
    end
  end
end

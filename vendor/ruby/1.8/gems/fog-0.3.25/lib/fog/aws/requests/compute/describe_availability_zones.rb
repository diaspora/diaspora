module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_availability_zones'

        # Describe all or specified availability zones
        #
        # ==== Params
        # * filters<~Hash> - List of filters to limit results with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'availabilityZoneInfo'<~Array>:
        #       * 'regionName'<~String> - Name of region
        #       * 'zoneName'<~String> - Name of zone
        #       * 'zoneState'<~String> - State of zone
        def describe_availability_zones(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_availability_zones with #{filters.class} param is deprecated, use describe_availability_zones('zone-name' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'public-ip' => [*filters]}
          end
          params = AWS.indexed_filters(filters)
          request({
            'Action'    => 'DescribeAvailabilityZones',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeAvailabilityZones.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_availability_zones(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_availability_zones with #{filters.class} param is deprecated, use describe_availability_zones('zone-name' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'public-ip' => [*filters]}
          end

          response = Excon::Response.new

          availability_zone_info = [
            {"messageSet" => [], "regionName" => "us-east-1", "zoneName" => "us-east-1a", "zoneState" => "available"},
            {"messageSet" => [], "regionName" => "us-east-1", "zoneName" => "us-east-1b", "zoneState" => "available"},
            {"messageSet" => [], "regionName" => "us-east-1", "zoneName" => "us-east-1c", "zoneState" => "available"},
            {"messageSet" => [], "regionName" => "us-east-1", "zoneName" => "us-east-1d", "zoneState" => "available"},
          ]

          aliases = {'region-name' => 'regionName', 'zone-name' => 'zoneName', 'state' => 'zoneState'}
          for filter_key, filter_value in filters
            aliased_key = aliases[filter_key]
            availability_zone_info = availability_zone_info.reject{|availability_zone| ![*filter_value].include?(availability_zone[aliased_key])}
          end

          response.status = 200
          response.body = {
            'availabilityZoneInfo'  => availability_zone_info,
            'requestId'             => Fog::AWS::Mock.request_id
          }
          response
        end

      end
    end
  end
end

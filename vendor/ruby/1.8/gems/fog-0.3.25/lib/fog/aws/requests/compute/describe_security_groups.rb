module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_security_groups'

        # Describe all or specified security groups
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # === Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'securityGroupInfo'<~Array>:
        #       * 'groupDescription'<~String> - Description of security group
        #       * 'groupName'<~String> - Name of security group
        #       * 'ipPermissions'<~Array>:
        #         * 'fromPort'<~Integer> - Start of port range (or -1 for ICMP wildcard)
        #         * 'groups'<~Array>:
        #           * 'groupName'<~String> - Name of security group
        #           * 'userId'<~String> - AWS User Id of account
        #         * 'ipProtocol'<~String> - Ip protocol, must be in ['tcp', 'udp', 'icmp']
        #         * 'ipRanges'<~Array>:
        #           * 'cidrIp'<~String> - CIDR range
        #         * 'toPort'<~Integer> - End of port range (or -1 for ICMP wildcard)
        #       * 'ownerId'<~String> - AWS Access Key Id of the owner of the security group
        def describe_security_groups(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_security_groups with #{filters.class} param is deprecated, use describe_security_groups('group-name' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'group-name' => [*filters]}
          end
          params = AWS.indexed_filters(filters)
          request({
            'Action'    => 'DescribeSecurityGroups',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeSecurityGroups.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_security_groups(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_security_groups with #{filters.class} param is deprecated, use describe_security_groups('group-name' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'group-name' => [*filters]}
          end

          response = Excon::Response.new

          security_group_info = @data[:security_groups].values

          aliases = {
            'description' => 'groupDescription',
            'group-name'  => 'groupName',
            'owner-id'    => 'ownerId'
          }
          permission_aliases = {
            'cidr'      => 'cidrIp',
            'from-port' => 'fromPort',
            'protocol'  => 'ipProtocol',
            'to-port'   => 'toPort'
          }
          for filter_key, filter_value in filters
            if permission_key = filter_key.split('ip-permission.')[1]
              if permission_key == 'group-name'
                security_group_info = security_group_info.reject{|security_group| !security_group['ipPermissions']['groups'].detect {|group| [*filter_value].include?(group['groupName'])}}
              elsif permission_key == 'user-id'
                security_group_info = security_group_info.reject{|security_group| !security_group['ipPermissions']['groups'].detect {|group| [*filter_value].include?(group['userId'])}}
              else
                aliased_key = permission_aliases[filter_key]
                security_group_info = security_group_info.reject{|security_group| !security_group['ipPermissions'].detect {|permission| [*filter_value].include?(permission[aliased_key])}}
              end
            else
              aliased_key = aliases[filter_key]
              security_group_info = security_group_info.reject{|security_group| ![*filter_value].include?(security_group[aliased_key])}
            end
          end

          response.status = 200
          response.body = {
            'requestId'         => Fog::AWS::Mock.request_id,
            'securityGroupInfo' => security_group_info
          }
          response
        end

      end
    end
  end
end

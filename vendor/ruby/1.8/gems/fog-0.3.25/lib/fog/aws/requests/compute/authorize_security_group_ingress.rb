module Fog
  module AWS
    class Compute
      class Real

        # Add permissions to a security group
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'GroupName'<~String> - Name of group
        #   * 'SourceSecurityGroupName'<~String> - Name of security group to authorize
        #   * 'SourceSecurityGroupOwnerId'<~String> - Name of owner to authorize
        #   or
        #   * 'CidrIp' - CIDR range
        #   * 'FromPort' - Start of port range (or -1 for ICMP wildcard)
        #   * 'GroupName' - Name of group to modify
        #   * 'IpProtocol' - Ip protocol, must be in ['tcp', 'udp', 'icmp']
        #   * 'ToPort' - End of port range (or -1 for ICMP wildcard)
        #
        # === Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def authorize_security_group_ingress(options = {})
          request({
            'Action'    => 'AuthorizeSecurityGroupIngress',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(options))
        end

      end

      class Mock

        def authorize_security_group_ingress(options = {})
          response = Excon::Response.new
          group = @data[:security_groups][options['GroupName']]

          if group
            group['ipPermissions'] ||= []
            if options['GroupName'] && options['SourceSecurityGroupName'] && options['SourceSecurityGroupOwnerId']
              ['tcp', 'udp'].each do |protocol|
                group['ipPermissions'] << {
                  'groups'      => [{'groupName' => options['GroupName'], 'userId' => @owner_id}],
                  'fromPort'    => 1,
                  'ipRanges'    => [],
                  'ipProtocol'  => protocol,
                  'toPort'      => 65535
                }
              end
              group['ipPermissions'] << {
                'groups'      => [{'groupName' => options['GroupName'], 'userId' => @owner_id}],
                'fromPort'    => -1,
                'ipRanges'    => [],
                'ipProtocol'  => 'icmp',
                'toPort'      => -1
              }
            else
              group['ipPermissions'] << {
                'groups'      => [],
                'fromPort'    => options['FromPort'],
                'ipRanges'    => [],
                'ipProtocol'  => options['IpProtocol'],
                'toPort'      => options['ToPort']
              }
              if options['CidrIp']
                group['ipPermissions'].last['ipRanges'] << { 'cidrIp' => options['CidrIp'] }
              end
            end
            response.status = 200
            response.body = {
              'requestId' => Fog::AWS::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::AWS::Compute::NotFound.new("The security group '#{options['GroupName']}' does not exist")
          end
        end

      end
    end
  end
end

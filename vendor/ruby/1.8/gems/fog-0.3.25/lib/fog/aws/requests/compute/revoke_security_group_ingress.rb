module Fog
  module AWS
    class Compute
      class Real

        # Remove permissions from a security group
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
        def revoke_security_group_ingress(options = {})
          request({
            'Action'    => 'RevokeSecurityGroupIngress',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(options))
        end

      end

      class Mock

        def revoke_security_group_ingress(options = {})
          response = Excon::Response.new
          group = @data[:security_groups][options['GroupName']]
          if group
            if options['GroupName'] && options['SourceSecurityGroupName'] && options['SourceSecurityGroupOwnerId']
              group['ipPermissions'].delete_if {|permission|
                permission['groups'].first['groupName'] == options['GroupName']
              }
            else
              ingress = group['ipPermissions'].select {|permission|
                permission['fromPort']    == options['FromPort'] &&
                permission['ipProtocol']  == options['IpProtocol'] &&
                permission['toPort']      == options['ToPort'] &&
                (
                  permission['ipRanges'].empty? ||
                  (
                    permission['ipRanges'].first &&
                    permission['ipRanges'].first['cidrIp'] == options['CidrIp']
                  )
                )
              }.first
              group['ipPermissions'].delete(ingress)
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

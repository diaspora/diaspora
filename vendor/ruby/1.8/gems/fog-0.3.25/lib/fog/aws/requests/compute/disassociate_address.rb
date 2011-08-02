module Fog
  module AWS
    class Compute
      class Real

        # Disassociate an elastic IP address from its instance (if any)
        #
        # ==== Parameters
        # * public_ip<~String> - Public ip to assign to instance
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def disassociate_address(public_ip)
          request(
            'Action'    => 'DisassociateAddress',
            'PublicIp'  => public_ip,
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          )
        end

      end

      class Mock

        def disassociate_address(public_ip)
          response = Excon::Response.new
          response.status = 200
          if address = @data[:addresses][public_ip]
            instance_id = address['instanceId']
            instance = @data[:instances][instance_id]
            instance['ipAddress']         = instance['originalIpAddress']
            instance['dnsName']           = Fog::AWS::Mock.dns_name_for(instance['ipAddress'])
            address['instanceId'] = nil
            response.status = 200
            response.body = {
              'requestId' => Fog::AWS::Mock.request_id,
              'return'    => true
            }
            response
          else
            raise Fog::AWS::Compute::Error.new("AuthFailure => The address '#{public_ip}' does not belong to you.")
          end
        end

      end
    end
  end
end

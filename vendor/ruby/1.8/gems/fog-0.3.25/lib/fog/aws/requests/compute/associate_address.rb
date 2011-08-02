module Fog
  module AWS
    class Compute
      class Real

        # Associate an elastic IP address with an instance
        #
        # ==== Parameters
        # * instance_id<~String> - Id of instance to associate address with
        # * public_ip<~String> - Public ip to assign to instance
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def associate_address(instance_id, public_ip)
          request(
            'Action'      => 'AssociateAddress',
            'InstanceId'  => instance_id,
            'PublicIp'    => public_ip,
            :idempotent   => true,
            :parser       => Fog::Parsers::AWS::Compute::Basic.new
          )
        end

      end

      class Mock

        def associate_address(instance_id, public_ip)
          response = Excon::Response.new
          response.status = 200
          instance = @data[:instances][instance_id]
          address = @data[:addresses][public_ip]
          if instance && address
            address['instanceId'] = instance_id
            instance['originalIpAddress'] = instance['ipAddress']
            instance['ipAddress'] = public_ip
            instance['dnsName'] = Fog::AWS::Mock.dns_name_for(public_ip)
            response.status = 200
            response.body = {
              'requestId' => Fog::AWS::Mock.request_id,
              'return'    => true
            }
            response
          elsif !instance
            raise Fog::AWS::Compute::NotFound.new("The instance ID '#{instance_id}' does not exist")
          elsif !address
            raise Fog::AWS::Compute::Error.new("AuthFailure => The address '#{public_ip}' does not belong to you.")
          end
        end

      end
    end
  end
end

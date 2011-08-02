module Fog
  module AWS
    class Compute
      class Real

        # Release an elastic IP address.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'return'<~Boolean> - success?
        def release_address(public_ip)
          request(
            'Action'    => 'ReleaseAddress',
            'PublicIp'  => public_ip,
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          )
        end

      end

      class Mock

        def release_address(public_ip)
          response = Excon::Response.new
          if (address = @data[:addresses].delete(public_ip))
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

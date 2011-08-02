module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/allocate_address'

        # Acquire an elastic IP address.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'publicIp'<~String> - The acquired address
        #     * 'requestId'<~String> - Id of the request
        def allocate_address
          request(
            'Action'  => 'AllocateAddress',
            :parser   => Fog::Parsers::AWS::Compute::AllocateAddress.new
          )
        end

      end

      class Mock

        def allocate_address
          response = Excon::Response.new
          if describe_addresses.body['addressesSet'].size < @data[:limits][:addresses]
            response.status = 200
            public_ip = Fog::AWS::Mock.ip_address
            data ={
              'instanceId' => nil,
              'publicIp'   => public_ip
            }
            @data[:addresses][public_ip] = data
            response.body = {
              'publicIp'  => public_ip,
              'requestId' => Fog::AWS::Mock.request_id
            }
            response
          else
            response.status = 400
            response.body = "<?xml version=\"1.0\"?><Response><Errors><Error><Code>AddressLimitExceeded</Code><Message>Too many addresses allocated</Message></Error></Errors><RequestID>#{Fog::AWS::Mock.request_id}</RequestID></Response>"
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
        end

      end
    end
  end
end

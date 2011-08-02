module Fog
  module AWS
    class Compute
      class Real

        # Delete a key pair that you own
        #
        # ==== Parameters
        # * key_name<~String> - Name of the key pair.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> id of request
        #     * 'return'<~Boolean> - success?
        def delete_key_pair(key_name)
          request(
            'Action'    => 'DeleteKeyPair',
            'KeyName'   => key_name,
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::Basic.new
          )
        end

      end

      class Mock

        def delete_key_pair(key_name)
          response = Excon::Response.new
          @data[:key_pairs].delete(key_name)
          response.status = 200
          response.body = {
            'requestId' => Fog::AWS::Mock.request_id,
            'return'    => true
          }
          response
        end

      end
    end
  end
end

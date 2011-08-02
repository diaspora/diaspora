module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Update an access key for a user
        # 
        # ==== Parameters
        # * access_key_id<~String> - Access key id to delete
        # * status<~String> - status of keys in ['Active', 'Inactive']
        # * options<~Hash>:
        #   * 'UserName'<~String> - name of the user to create (do not include path)
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_UpdateAccessKey.html
        #
        def update_access_key(access_key_id, status, options = {})
          request({
            'AccessKeyId' => access_key_id,
            'Action'      => 'UpdateAccessKey',
            'Status'      => status,
            :parser       => Fog::Parsers::AWS::IAM::Basic.new
          }.merge!(options))
        end

      end

      class Mock

        def update_access_key(access_key_id, status, user_name = nil)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

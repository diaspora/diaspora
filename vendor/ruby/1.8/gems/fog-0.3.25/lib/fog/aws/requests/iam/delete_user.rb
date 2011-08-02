module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Delete a user
        # 
        # ==== Parameters
        # * user_name<~String>: name of the user to delete
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_DeleteUser.html
        #
        def delete_user(user_name)
          request(
            'Action'    => 'DeleteUser',
            'UserName'  => user_name,
            :parser     => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def delete_user(user_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

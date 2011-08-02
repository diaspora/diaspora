module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Remove a policy from a user
        # 
        # ==== Parameters
        # * user_name<~String>: name of the user
        # * policy_name<~String>: name of policy document
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_DeleteUserPolicy.html
        #
        def delete_user_policy(user_name, policy_name)
          request(
            'Action'          => 'DeleteUserPolicy',
            'PolicyName'      => policy_name,
            'UserName'        => user_name,
            :parser           => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def delete_user_policy(user_name, policy_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

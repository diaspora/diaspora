module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Add or update a policy for a user
        # 
        # ==== Parameters
        # * user_name<~String>: name of the user
        # * policy_name<~String>: name of policy document
        # * policy_document<~Hash>: policy document, see: http://docs.amazonwebservices.com/IAM/latest/UserGuide/PoliciesOverview.html
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_PutUserPolicy.html
        #
        def put_user_policy(user_name, policy_name, policy_document)
          request(
            'Action'          => 'PutUserPolicy',
            'PolicyName'      => policy_name,
            'PolicyDocument'  => policy_document.to_json,
            'UserName'        => user_name,
            :parser           => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def put_user_policy(user_name, policy_name, policy_document)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

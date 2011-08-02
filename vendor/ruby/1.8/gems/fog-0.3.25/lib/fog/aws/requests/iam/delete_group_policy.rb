module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Remove a policy from a group
        # 
        # ==== Parameters
        # * group_name<~String>: name of the group
        # * policy_name<~String>: name of policy document
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_DeleteGroupPolicy.html
        #
        def delete_group_policy(group_name, policy_name)
          request(
            'Action'          => 'DeleteGroupPolicy',
            'GroupName'       => group_name,
            'PolicyName'      => policy_name,
            :parser           => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def delete_group_policy(group_name, policy_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

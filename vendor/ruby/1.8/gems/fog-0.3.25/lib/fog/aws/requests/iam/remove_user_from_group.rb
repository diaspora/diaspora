module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Remove a user from a group
        # 
        # ==== Parameters
        # * group_name<~String>: name of the group
        # * user_name<~String>: name of user to remove
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_RemoveUserFromGroup.html
        #
        def remove_user_from_group(group_name, user_name)
          request(
            'Action'    => 'RemoveUserFromGroup',
            'GroupName' => group_name,
            'UserName'  => user_name,
            :parser     => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def remove_user_from_group(group_name, user_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

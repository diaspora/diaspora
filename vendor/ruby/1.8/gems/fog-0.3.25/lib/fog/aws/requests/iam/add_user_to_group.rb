module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Add a user to a group
        # 
        # ==== Parameters
        # * group_name<~String>: name of the group
        # * user_name<~String>: name of user to add
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_AddUserToGroup.html
        #
        def add_user_to_group(group_name, user_name)
          request(
            'Action'    => 'AddUserToGroup',
            'GroupName' => group_name,
            'UserName'  => user_name,
            :parser     => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def add_user_to_group(group_name, user_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

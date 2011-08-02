module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/basic'

        # Delete a group
        # 
        # ==== Parameters
        # * group_name<~String>: name of the group to delete
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_DeleteGroup.html
        #
        def delete_group(group_name)
          request(
            'Action'    => 'DeleteGroup',
            'GroupName' => group_name,
            :parser     => Fog::Parsers::AWS::IAM::Basic.new
          )
        end

      end

      class Mock

        def delete_group(group_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

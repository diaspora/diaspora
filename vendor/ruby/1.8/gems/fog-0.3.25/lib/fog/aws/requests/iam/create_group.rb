module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/create_group'

        # Create a new group
        # 
        # ==== Parameters
        # * group_name<~String>: name of the group to create (do not include path)
        # * path<~String>: optional path to group, defaults to '/'
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Group'<~Hash>:
        #       * Arn<~String> -
        #       * GroupId<~String> -
        #       * GroupName<~String> -
        #       * Path<~String> -
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_CreateGroup.html
        #
        def create_group(group_name, path = '/')
          request(
            'Action'    => 'CreateGroup',
            'GroupName' => group_name,
            'Path'      => path,
            :parser     => Fog::Parsers::AWS::IAM::CreateGroup.new
          )
        end

      end

      class Mock

        def create_group(group_name, path = '/')
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

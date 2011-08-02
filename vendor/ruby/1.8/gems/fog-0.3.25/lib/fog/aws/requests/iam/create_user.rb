module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/create_user'

        # Create a new user
        # 
        # ==== Parameters
        # * user_name<~String>: name of the user to create (do not include path)
        # * path<~String>: optional path to group, defaults to '/'
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'User'<~Hash>:
        #       * 'Arn'<~String> -
        #       * 'Path'<~String> -
        #       * 'UserId'<~String> -
        #       * 'UserName'<~String> -
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_CreateUser.html
        #
        def create_user(user_name, path = '/')
          request(
            'Action'    => 'CreateUser',
            'UserName'  => user_name,
            'Path'      => path,
            :parser     => Fog::Parsers::AWS::IAM::CreateUser.new
          )
        end

      end

      class Mock

        def create_user(user_name, path = '/')
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

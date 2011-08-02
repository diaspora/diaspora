module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/list_users'

        # List users
        # 
        # ==== Parameters
        # * options<~Hash>:
        #   * 'Marker'<~String>: used to paginate subsequent requests
        #   * 'MaxItems'<~Integer>: limit results to this number per page
        #   * 'PathPrefix'<~String>: prefix for filtering results
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Users'<~Array> - Matching groups
        #       * user<~Hash>:
        #         * Arn<~String> -
        #         * Path<~String> -
        #         * UserId<~String> -
        #         * UserName<~String> -
        #     * 'IsTruncated<~Boolean> - Whether or not results were truncated
        #     * 'Marker'<~String> - appears when IsTruncated is true as the next marker to use
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_ListUsers.html
        #
        def list_users(options = {})
          request({
            'Action'  => 'ListUsers',
            :parser   => Fog::Parsers::AWS::IAM::ListUsers.new
          }.merge!(options))
        end

      end

      class Mock

        def list_users(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

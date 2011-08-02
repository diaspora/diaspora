module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/list_access_keys'

        # List access_keys
        # 
        # ==== Parameters
        # * options<~Hash>:
        #   * 'Marker'<~String> - used to paginate subsequent requests
        #   * 'MaxItems'<~Integer> - limit results to this number per page
        #   * 'UserName'<~String> - optional: username to lookup access keys for, defaults to current user
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'AccessKeys'<~Array> - Matching access keys
        #       * access_key<~Hash>:
        #         * AccessKeyId<~String> -
        #         * Status<~String> -
        #     * 'IsTruncated<~Boolean> - Whether or not results were truncated
        #     * 'Marker'<~String> - appears when IsTruncated is true as the next marker to use
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_ListAccessKeys.html
        #
        def list_access_keys(options = {})
          request({
            'Action'  => 'ListAccessKeys',
            :parser   => Fog::Parsers::AWS::IAM::ListAccessKeys.new
          }.merge!(options))
        end

      end

      class Mock

        def list_access_keys(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

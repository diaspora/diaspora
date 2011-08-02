module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/list_groups'

        # List groups
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
        #     * 'Groups'<~Array> - Matching groups
        #       * group<~Hash>:
        #         * Arn<~String> -
        #         * GroupId<~String> -
        #         * GroupName<~String> -
        #         * Path<~String> -
        #     * 'IsTruncated<~Boolean> - Whether or not results were truncated
        #     * 'Marker'<~String> - appears when IsTruncated is true as the next marker to use
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_ListGroups.html
        #
        def list_groups(options = {})
          request({
            'Action'  => 'ListGroups',
            :parser   => Fog::Parsers::AWS::IAM::ListGroups.new
          }.merge!(options))
        end

      end

      class Mock

        def list_groups(options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

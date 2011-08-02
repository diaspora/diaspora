module Fog
  module AWS
    class IAM
      class Real

        require 'fog/aws/parsers/iam/list_policies'

        # List policies for a user
        # 
        # ==== Parameters
        # * user_name<~String> - Name of user to list policies for
        # * options<~Hash>: Optional
        #   * 'Marker'<~String>: used to paginate subsequent requests
        #   * 'MaxItems'<~Integer>: limit results to this number per page
        #   * 'PathPrefix'<~String>: prefix for filtering results
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'PolicyNames'<~Array> - Matching policy names
        #     * 'IsTruncated<~Boolean> - Whether or not results were truncated
        #     * 'Marker'<~String> - appears when IsTruncated is true as the next marker to use
        #     * 'RequestId'<~String> - Id of the request
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/IAM/latest/APIReference/API_ListUserPolicies.html
        #
        def list_user_policies(user_name, options = {})
          request({
            'Action'    => 'ListUserPolicies',
            'UserName'  => user_name,
            :parser     => Fog::Parsers::AWS::IAM::ListPolicies.new
          }.merge!(options))
        end

      end

      class Mock

        def list_user_policies(user_name, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

module Fog
  module AWS
    class CDN
      class Real

        require 'fog/aws/parsers/cdn/post_invalidation'

        # List information about distributions in CloudFront
        #
        # ==== Parameters
        # * distribution_id<~String> - Id of distribution for invalidations
        # * paths<~Array> - Array of string paths to objects to invalidate
        # * caller_reference<~String> - Used to prevent replay, defaults to Time.now.to_i.to_s
        #
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Id'<~String> - Id of invalidation
        #     * 'Status'<~String> - Status of invalidation
        #     * 'CreateTime'<~Integer> - Time of invalidation creation
        #     * 'InvalidationBatch'<~Array>:
        #       * 'Path'<~Array> - Array of strings of objects to invalidate
        #       * 'CallerReference'<~String> - Used to prevent replay, defaults to Time.now.to_i.to_s
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonCloudFront/latest/APIReference/CreateInvalidation.html

        def post_invalidation(distribution_id, paths, caller_reference = Time.now.to_i.to_s)
          body = '<?xml version="1.0" encoding="UTF-8"?>'
          body << "<InvalidationBatch>"
          for path in [*paths]
            body << "<Path>" << path << "</Path>"
          end
          body << "<CallerReference>" << caller_reference << "</CallerReference>"
          body << "</InvalidationBatch>"
          request({
            :body       => body,
            :expects    => 201,
            :headers    => {'Content-Type' => 'text/xml'},
            :idempotent => true,
            :method     => 'POST',
            :parser     => Fog::Parsers::AWS::CDN::PostInvalidation.new,
            :path       => "/distribution/#{distribution_id}/invalidation"
          })
        end

      end

      class Mock # :nodoc:all

        def post_invalidation(distribution_id, paths, caller_reference = Time.now.to_i.to_s)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

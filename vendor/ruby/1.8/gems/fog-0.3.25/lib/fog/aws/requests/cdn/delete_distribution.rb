module Fog
  module AWS
    class CDN
      class Real

        # Delete a distribution from CloudFront
        #
        # ==== Parameters
        # * distribution_id<~String> - Id of distribution to delete
        # * etag<~String> - etag of that distribution from earlier get or put
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonCloudFront/latest/APIReference/DeleteDistribution.html

        def delete_distribution(distribution_id, etag)
          request({
            :expects    => 204,
            :headers    => { 'If-Match' => etag },
            :idempotent => true,
            :method     => 'DELETE',
            :path       => "/distribution/#{distribution_id}"
          })
        end

      end

      class Mock # :nodoc:all

        def delete_distribution(distribution_id, etag)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

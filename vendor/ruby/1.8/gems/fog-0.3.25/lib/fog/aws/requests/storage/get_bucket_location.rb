module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/get_bucket_location'

        # Get location constraint for an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to get location constraint for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'LocationConstraint'<~String> - Location constraint of the bucket
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketGETlocation.html

        def get_bucket_location(bucket_name)
          request({
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :idempotent => true,
            :method   => 'GET',
            :parser   => Fog::Parsers::AWS::Storage::GetBucketLocation.new,
            :query    => {'location' => nil}
          })
        end

      end

      class Mock # :nodoc:all

        def get_bucket_location(bucket_name)
          response = Excon::Response.new
          if bucket = @data[:buckets][bucket_name]
            response.status = 200
            response.body = {'LocationConstraint' => bucket['LocationConstraint'] }
          else
            response.status = 404
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end

      end
    end
  end
end

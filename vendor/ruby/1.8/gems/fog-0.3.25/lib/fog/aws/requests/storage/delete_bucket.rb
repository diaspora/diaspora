module Fog
  module AWS
    class Storage
      class Real

        # Delete an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to delete
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * status<~Integer> - 204
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketDELETE.html

        def delete_bucket(bucket_name)
          request({
            :expects  => 204,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'DELETE'
          })
        end

      end

      class Mock # :nodoc:all

        def delete_bucket(bucket_name)
          response = Excon::Response.new
          if @data[:buckets][bucket_name].nil?
            response.status = 404
            raise(Excon::Errors.status_error({:expects => 204}, response))
          elsif @data[:buckets][bucket_name] && !@data[:buckets][bucket_name][:objects].empty?
            response.status = 409
            raise(Excon::Errors.status_error({:expects => 204}, response))
          else
            @data[:buckets].delete(bucket_name)
            response.status = 204
          end
          response
        end

      end

    end
  end
end

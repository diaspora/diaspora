module Fog
  module AWS
    class Storage
      class Real

        # Change versioning status for an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to modify
        # * status<~String> - Status to change to in ['Enabled', 'Suspended']
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketPUTVersioningStatus.html

        def put_bucket_versioning(bucket_name, status)
          data =
<<-DATA
<VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Status>#{status}</Status>
</VersioningConfiguration>
DATA

          request({
            :body     => data,
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'PUT',
            :query    => {'versioning' => nil}
          })
        end

      end

      class Mock # :nodoc:all

        def put_bucket_versioning(bucket_name, status)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

module Fog
  module AWS
    class Storage
      class Real

        # Abort a multipart upload
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to abort multipart upload on
        # * object_name<~String> - Name of object to abort multipart upload on
        # * upload_id<~String> - Id of upload to add part to
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/mpUploadAbort.html
        #
        def abort_multipart_upload(bucket_name, object_name, upload_id)
          request({
            :expects    => 204,
            :headers    => {},
            :host       => "#{bucket_name}.#{@host}",
            :method     => 'DELETE',
            :path       => CGI.escape(object_name),
            :query      => {'uploadId' => upload_id}
          })
        end

      end # Real

      class Mock # :nodoc:all

        def abort_multipart_upload(bucket_name, object_name, upload_id)
          Fog::Mock.not_implemented
        end

      end # Mock
    end # Storage
  end # AWS
end # Fog
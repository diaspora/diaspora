module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/complete_multipart_upload'

        # Complete a multipart upload
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to complete multipart upload for
        # * object_name<~String> - Name of object to complete multipart upload for
        # * upload_id<~String> - Id of upload to add part to
        # * parts<~Array>: Array of etags for parts
        #   * :etag<~String> - Etag for this part
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * headers<~Hash>:
        #     * 'Bucket'<~String> - bucket of new object
        #     * 'ETag'<~String> - etag of new object (will be needed to complete upload)
        #     * 'Key'<~String> - key of new object
        #     * 'Location'<~String> - location of new object
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/mpUploadComplete.html
        #
        def complete_multipart_upload(bucket_name, object_name, upload_id, parts)
          data = "<CompleteMultipartUpload>"
          parts.each_with_index do |part, index|
            data << "<Part>"
            data << "<PartNumber>#{index + 1}</PartNumber>"
            data << "<ETag>#{part}</ETag>"
            data << "</Part>"
          end
          data << "</CompleteMultipartUpload>"
          request({
            :body       => data,
            :expects    => 200,
            :headers    => { 'Content-Length' => data.length },
            :host       => "#{bucket_name}.#{@host}",
            :method     => 'POST',
            :parser     => Fog::Parsers::AWS::Storage::CompleteMultipartUpload.new,
            :path       => CGI.escape(object_name),
            :query      => {'uploadId' => upload_id}
          })
        end

      end # Real

      class Mock # :nodoc:all

        def complete_multipart_upload(bucket_name, object_name, upload_id, parts)
          Fog::Mock.not_implemented
        end

      end # Mock
    end # Storage
  end # AWS
end # Fog
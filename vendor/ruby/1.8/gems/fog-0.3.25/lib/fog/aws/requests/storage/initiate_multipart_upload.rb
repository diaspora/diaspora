module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/initiate_multipart_upload'

        # Initiate a multipart upload to an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to create object in
        # * object_name<~String> - Name of object to create
        # * options<~Hash>:
        #   * 'Cache-Control'<~String> - Caching behaviour
        #   * 'Content-Disposition'<~String> - Presentational information for the object
        #   * 'Content-Encoding'<~String> - Encoding of object data
        #   * 'Content-MD5'<~String> - Base64 encoded 128-bit MD5 digest of message (defaults to Base64 encoded MD5 of object.read)
        #   * 'Content-Type'<~String> - Standard MIME type describing contents (defaults to MIME::Types.of.first)
        #   * 'x-amz-acl'<~String> - Permissions, must be in ['private', 'public-read', 'public-read-write', 'authenticated-read']
        #   * "x-amz-meta-#{name}" - Headers to be returned with object, note total size of request without body must be less than 8 KB.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Bucket'<~String> - Bucket where upload was initiated
        #     * 'Key'<~String> - Object key where the upload was initiated
        #     * 'UploadId'<~String> - Id for initiated multipart upload
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/mpUploadInitiate.html
        #
        def initiate_multipart_upload(bucket_name, object_name, options = {})
          request({
            :expects    => 200,
            :headers    => options,
            :host       => "#{bucket_name}.#{@host}",
            :method     => 'POST',
            :parser     => Fog::Parsers::AWS::Storage::InitiateMultipartUpload.new,
            :path       => CGI.escape(object_name),
            :query      => {'uploads' => nil}
          })
        end

      end # Real

      class Mock # :nodoc:all

        def initiate_multipart_upload(bucket_name, object_name, options = {})
          Fog::Mock.not_implemented
        end

      end # Mock
    end # Storage
  end # AWS
end # Fog
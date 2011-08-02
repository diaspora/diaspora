module Fog
  module AWS
    class Storage
      class Real

        # Upload a part for a multipart upload
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to add part to
        # * object_name<~String> - Name of object to add part to
        # * upload_id<~String> - Id of upload to add part to
        # * part_number<~String> - Index of part in upload
        # * data<~File||String> - Content for part
        # * options<~Hash>:
        #   * 'Content-MD5'<~String> - Base64 encoded 128-bit MD5 digest of message
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * headers<~Hash>:
        #     * 'ETag'<~String> - etag of new object (will be needed to complete upload)
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/mpUploadUploadPart.html
        #
        def upload_part(bucket_name, object_name, upload_id, part_number, data, options = {})
          data = parse_data(data)
          headers = options
          headers['Content-Length'] = data[:headers]['Content-Length']
          request({
            :body       => data[:body],
            :expects    => 200,
            :headers    => headers,
            :host       => "#{bucket_name}.#{@host}",
            :method     => 'PUT',
            :path       => CGI.escape(object_name),
            :query      => {'uploadId' => upload_id, 'partNumber' => part_number}
          })
        end

      end # Real

      class Mock # :nodoc:all

        def upload_part(bucket_name, object_name, upload_id, part_number, data, options = {})
          Fog::Mock.not_implemented
        end

      end # Mock
    end # Storage
  end # AWS
end # Fog
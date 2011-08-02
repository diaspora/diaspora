module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/list_parts'

        # List parts for a multipart upload
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to list parts for
        # * object_name<~String> - Name of object to list parts for
        # * upload_id<~String> - upload id to list objects for
        # * options<~Hash> - config arguments for list.  Defaults to {}.
        #   * 'max-parts'<~Integer> - limits number of parts returned
        #   * 'part-number-marker'<~String> - limits parts to only those that appear
        #     lexicographically after this part number.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Bucket'<~string> - Bucket where the multipart upload was initiated
        #     * 'Initiator'<~Hash>:
        #       * 'DisplayName'<~String> - Display name of upload initiator
        #       * 'ID'<~String> - Id of upload initiator
        #     * 'IsTruncated'<~Boolean> - Whether or not the listing is truncated
        #     * 'Key'<~String> - Key where multipart upload was initiated
        #     * 'MaxParts'<~String> - maximum number of replies alllowed in response
        #     * 'NextPartNumberMarker'<~String> - last item in list, for further pagination
        #     * 'Part'<~Array>:
        #       * 'ETag'<~String> - ETag of part
        #       * 'LastModified'<~Timestamp> - Last modified for part
        #       * 'PartNumber'<~String> - Part number for part
        #       * 'Size'<~Integer> - Size of part
        #     * 'PartNumberMarker'<~String> - Part number after which listing begins
        #     * 'StorageClass'<~String> - Storage class of object
        #     * 'UploadId'<~String> - upload id of upload containing part
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/mpUploadListParts.html
        #
        def list_parts(bucket_name, object_name, upload_id, options = {})
          options['uploadId'] = upload_id
          request({
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :idempotent => true,
            :method   => 'GET',
            :parser   => Fog::Parsers::AWS::Storage::ListParts.new,
            :path     => CGI.escape(object_name),
            :query    => options.merge!({'uploadId' => upload_id})
          })
        end

      end

      class Mock # :nodoc:all

        def list_parts(bucket_name, object_name, upload_id, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

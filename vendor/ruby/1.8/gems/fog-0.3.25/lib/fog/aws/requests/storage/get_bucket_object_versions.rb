module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/get_bucket_object_versions'

        # List information about object versions in an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to list object keys from
        # * options<~Hash> - config arguments for list.  Defaults to {}.
        #   * 'delimiter'<~String> - causes keys with the same string between the prefix
        #     value and the first occurence of delimiter to be rolled up
        #   * 'key-marker'<~String> - limits object keys to only those that appear
        #     lexicographically after its value.
        #   * 'max-keys'<~Integer> - limits number of object keys returned
        #   * 'prefix'<~String> - limits object keys to those beginning with its value.
        #   * 'version-id-marker'<~String> - limits object versions to only those that
        #     appear lexicographically after its value
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Delimeter'<~String> - Delimiter specified for query
        #     * 'KeyMarker'<~String> - Key marker specified for query
        #     * 'MaxKeys'<~Integer> - Maximum number of keys specified for query
        #     * 'Name'<~String> - Name of the bucket
        #     * 'Prefix'<~String> - Prefix specified for query
        #     * 'VersionIdMarker'<~String> - Version id marker specified for query
        #     * 'IsTruncated'<~Boolean> - Whether or not this is the totality of the bucket
        #     * 'Versions'<~Array>:
        #         * 'DeleteMarker'<~Hash>:
        #           * 'IsLatest'<~Boolean> - Whether or not this is the latest version
        #           * 'Key'<~String> - Name of object
        #           * 'LastModified'<~String>: Timestamp of last modification of object
        #           * 'Owner'<~Hash>:
        #             * 'DisplayName'<~String> - Display name of object owner
        #             * 'ID'<~String> - Id of object owner
        #           * 'VersionId'<~String> - The id of this version
        #       or
        #         * 'Version'<~Hash>:
        #           * 'ETag'<~String>: Etag of object
        #           * 'IsLatest'<~Boolean> - Whether or not this is the latest version
        #           * 'Key'<~String> - Name of object
        #           * 'LastModified'<~String>: Timestamp of last modification of object
        #           * 'Owner'<~Hash>:
        #             * 'DisplayName'<~String> - Display name of object owner
        #             * 'ID'<~String> - Id of object owner
        #           * 'Size'<~Integer> - Size of object
        #           * 'StorageClass'<~String> - Storage class of object
        #           * 'VersionId'<~String> - The id of this version
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketGETVersion.html

        def get_bucket_object_versions(bucket_name, options = {})
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end
          request({
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :idempotent => true,
            :method   => 'GET',
            :parser   => Fog::Parsers::AWS::Storage::GetBucketObjectVersions.new,
            :query    => {'versions' => nil}.merge!(options)
          })
        end

      end

      class Mock # :nodoc:all

        def get_bucket_object_versions(bucket_name, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

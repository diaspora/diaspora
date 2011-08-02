module Fog
  module AWS
    class Storage
      class Real

        require 'fog/aws/parsers/storage/get_bucket_logging'

        # Get logging status for an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to get logging status for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'BucketLoggingStatus'<~Hash>: (will be empty if logging is disabled)
        #       * 'LoggingEnabled'<~Hash>:
        #         * 'TargetBucket'<~String> - bucket where logs are stored
        #         * 'TargetPrefix'<~String> - prefix logs are stored with
        #         * 'TargetGrants'<~Array>:
        #           * 'Grant'<~Hash>:
        #             * 'Grantee'<~Hash>:
        #                 * 'DisplayName'<~String> - Display name of grantee
        #                 * 'ID'<~String> - Id of grantee
        #               or
        #                 * 'URI'<~String> - URI of group to grant access for
        #             * 'Permission'<~String> - Permission, in [FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP]
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketGETlogging.html

        def get_bucket_logging(bucket_name)
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end
          request({
            :expects    => 200,
            :headers    => {},
            :host       => "#{bucket_name}.#{@host}",
            :idempotent => true,
            :method     => 'GET',
            :parser     => Fog::Parsers::AWS::Storage::GetBucketLogging.new,
            :query      => {'logging' => nil}
          })
        end

      end

      class Mock # :nodoc:all

        def get_bucket_logging(bucket_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

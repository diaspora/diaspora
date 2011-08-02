module Fog
  module AWS
    class Storage
      class Real

        # Change logging status for an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to modify
        # * logging_status<~Hash>:
        #   * Owner<~Hash>:
        #     * ID<~String>: id of owner
        #     * DisplayName<~String>: display name of owner
        #   * AccessControlList<~Array>:
        #     * Grantee<~Hash>:
        #         * 'DisplayName'<~String> - Display name of grantee
        #         * 'ID'<~String> - Id of grantee
        #       or
        #         * 'EmailAddress'<~String> - Email address of grantee
        #       or
        #         * 'URI'<~String> - URI of group to grant access for
        #     * Permission<~String> - Permission, in [FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP]
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketPUTlogging.html

        def put_bucket_logging(bucket_name, logging_status)
          if logging_status['LoggingEnabled'].empty?
            data =
<<-DATA
<BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01" />
DATA
          else
            data =
<<-DATA
<BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01">
  <LoggingEnabled>
    <TargetBucket>#{logging_status['LoggingEnabled']['TargetBucket']}</TargetBucket>
    <TargetPrefix>#{logging_status['LoggingEnabled']['TargetBucket']}</TargetPrefix>
    <TargetGrants>
DATA

            acl['AccessControlList'].each do |grant|
              data << "      <Grant>"
              type = case grant['Grantee'].keys.sort
              when ['DisplayName', 'ID']
                'CanonicalUser'
              when ['EmailAddress']
                'AmazonCustomerByEmail'
              when ['URI']
                'Group'
              end
              data << "        <Grantee xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"#{type}\">"
              for key, value in grant['Grantee']
                data << "          <#{key}>#{value}</#{key}>"
              end
              data << "        </Grantee>"
              data << "        <Permission>#{grant['Permission']}</Permission>"
              data << "      </Grant>"
            end

            data <<
<<-DATA
    </TargetGrants>
  </LoggingEnabled>
</BucketLoggingStatus>
DATA
          end

          request({
            :body     => data,
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'PUT',
            :query    => {'logging' => nil}
          })
        end

      end

      class Mock # :nodoc:all

        def put_bucket_logging(bucket_name, logging_status)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

module Fog
  module AWS
    class Storage
      class Real

        # Change access control list for an S3 object
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to modify
        # * object_name<~String> - name of object to get access control list for
        # * acl<~Hash>:
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
        # * options<~Hash>:
        #   * 'versionId'<~String> - specify a particular version to retrieve
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTObjectPUTacl.html

        def put_object_acl(bucket_name, object_name, acl, options = {})
          query = {'acl' => nil}
          if version_id = options.delete('versionId')
            query['versionId'] = version_id
          end

          data =
<<-DATA
<AccessControlPolicy>
  <Owner>
    <ID>#{acl['Owner']['ID']}</ID>
    <DisplayName>#{acl['Owner']['DisplayName']}</DisplayName>
  </Owner>
  <AccessControlList>
DATA

          acl['AccessControlList'].each do |grant|
            data << "    <Grant>"
            type = case grant['Grantee'].keys.sort
            when ['DisplayName', 'ID']
              'CanonicalUser'
            when ['EmailAddress']
              'AmazonCustomerByEmail'
            when ['URI']
              'Group'
            end
            data << "      <Grantee xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"#{type}\">"
            for key, value in grant['Grantee']
              data << "        <#{key}>#{value}</#{key}>"
            end
            data << "      </Grantee>"
            data << "      <Permission>#{grant['Permission']}</Permission>"
            data << "    </Grant>"
          end

          data <<
<<-DATA
  </AccessControlList>
</AccessControlPolicy>
DATA

          request({
            :body     => data,
            :expects  => 200,
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'PUT',
            :path       => CGI.escape(object_name),
            :query    => query
          })
        end

      end

      class Mock # :nodoc:all

        def put_object_acl(bucket_name, object_name, options, acl)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

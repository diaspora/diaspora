module Fog
  module Google
    class Storage
      class Real

        # Change access control list for an Google Storage bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to modify
        # * acl<~Hash>:
        #   * Owner<~Hash>:
        #     * ID<~String>: id of owner
        #     * DisplayName<~String>: display name of owner
        #   * AccessControlList<~Array>:
        #     * scope<~Hash>:
        #         * 'type'<~String> - 'UserById'
        #         * 'ID'<~String> - Id of grantee
        #       or
        #         * 'type'<~String> - 'UserByEmail'
        #         * 'EmailAddress'<~String> - Email address of grantee
        #       or
        #         * 'type'<~String> - type of user to grant permission to
        #     * Permission<~String> - Permission, in [FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP]
        def put_bucket_acl(bucket_name, acl)
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
            :query    => {'acl' => nil}
          })
        end

      end

      class Mock

        def put_bucket_acl(bucket_name, acl)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

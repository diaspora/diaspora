module Fog
  module Google
    class Storage
      class Real

        # Get torrent for an Google Storage object
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket containing object
        # * object_name<~String> - name of object to get torrent for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'AccessControlPolicy'<~Hash>
        #       * 'Owner'<~Hash>:
        #         * 'DisplayName'<~String> - Display name of object owner
        #         * 'ID'<~String> - Id of object owner
        #       * 'AccessControlList'<~Array>:
        #         * 'Grant'<~Hash>:
        #           * 'Grantee'<~Hash>:
        #             * 'DisplayName'<~String> - Display name of grantee
        #             * 'ID'<~String> - Id of grantee
        #           * 'Permission'<~String> - Permission, in [FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP]
        #
        def get_object_torrent(bucket_name, object_name)
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end
          unless object_name
            raise ArgumentError.new('object_name is required')
          end
          request({
            :expects    => 200,
            :headers    => {},
            :host       => "#{bucket_name}.#{@host}",
            :idempotent => true,
            :method     => 'GET',
            :path       => CGI.escape(object_name),
            :query      => {'torrent' => nil}
          })
        end

      end

      class Mock

        def get_object_object(bucket_name, object_name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

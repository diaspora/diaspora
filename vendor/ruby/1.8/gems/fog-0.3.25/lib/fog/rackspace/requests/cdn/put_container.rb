module Fog
  module Rackspace
    class CDN
      class Real

        # modify CDN properties for a container
        #
        # ==== Parameters
        # * name<~String> - Name for container, should be < 256 bytes and must not contain '/'
        # # options<~Hash>:
        #   * 'X-CDN-Enabled'<~Boolean> - cdn status for container
        #   * 'X-CDN-URI'<~String> - cdn url for this container
        #   * 'X-TTL'<~String> - integer seconds before data expires, defaults to 86400 (1 day), in 3600..259200
        #   * 'X-Log-Retention'<~Boolean> - ?
        #   * 'X-User-Agent-ACL'<~String> - ?
        #   * 'X-Referrer-ACL'<~String> - ?
        def put_container(name, options = {})
          response = request(
            :expects  => [201, 202],
            :headers  => options,
            :method   => 'PUT',
            :path     => CGI.escape(name)
          )
          response
        end

      end

      class Mock

        def put_container(name, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

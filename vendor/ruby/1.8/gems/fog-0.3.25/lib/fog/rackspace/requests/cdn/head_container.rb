module Fog
  module Rackspace
    class CDN
      class Real

        # List cdn properties for a container
        #
        # ==== Parameters
        # * container<~String> - Name of container to retrieve info for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * headers<~Hash>:
        #     * 'X-CDN-Enabled'<~Boolean> - cdn status for container
        #     * 'X-CDN-URI'<~String> - cdn url for this container
        #     * 'X-TTL'<~String> - integer seconds before data expires, defaults to 86400 (1 day)
        #     * 'X-Log-Retention'<~Boolean> - ?
        #     * 'X-User-Agent-ACL'<~String> - ?
        #     * 'X-Referrer-ACL'<~String> - ?
        def head_container(container)
          response = request(
            :expects  => 204,
            :method   => 'HEAD',
            :path     => container,
            :query    => {'format' => 'json'}
          )
          response
        end

      end

      class Mock

        def head_container(container)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

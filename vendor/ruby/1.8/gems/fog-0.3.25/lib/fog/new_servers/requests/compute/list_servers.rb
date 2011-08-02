module Fog
  module NewServers
    class Compute
      class Real

        # List servers
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * server<~Hash>:
        #       * 'id'<~String>     - Id of the server
        #       * 'ip'<~Hash>:
        #         * 'address'<~String>  - Address of the ip
        #         * 'name'<~String>     - Name of the ip
        #       * 'login'<~Hash>:
        #         * 'name'<~String>     - Name of the login
        #         * 'password'<~String> - Password of the login
        #         * 'username'<~String> - Username of the login
        #       * 'name'<~String>   - Name of the server
        #       * 'notes'<~String>  - Notes about the server
        #       * 'state'<~String>  - State of the server
        #
        def list_servers
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::ToHashDocument.new,
            :path     => 'api/listServers'
          )
        end

      end

      class Mock

        def list_servers
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

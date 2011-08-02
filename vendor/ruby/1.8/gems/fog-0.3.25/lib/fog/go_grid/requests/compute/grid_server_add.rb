module Fog
  module GoGrid
    class Compute
      class Real

        # Create a new server
        #
        # ==== Parameters
        # * 'image'<~String>  - image to use, in grid_image_list
        # * 'ip'<~String> - initial public ip for this server
        # * 'name'<~String>   - name of the server, 20 or fewer characters
        # * 'server_ram'<~String> - flavor to use, in common_lookup_list('server.ram')
        # * 'options'<~Hash>:
        #   * 'description'<~String>  - description of this server
        #   * 'isSandbox'<~String>    - treat this server as image sandbox? in ['true', 'false']
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_server_add(image, ip, name, server_ram, options={})
          request(
            :path     => 'grid/server/add',
            :query    => {
              'image'       => image,
              'ip'          => ip,
              'name'        => name,
              'server.ram'  => server_ram
            }.merge!(options)
          )
        end

      end

      class Mock

        def grid_server_add(image, ip, name, server_ram, options={})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

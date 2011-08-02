module Fog
  module Rackspace
    class Compute
      class Real

        # Create an image from a running server
        #
        # ==== Parameters
        # * server_id<~Integer> - Id of server to create image from
        # * options<~Hash> - Name
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * 'image'<~Hash>:
        #     * 'id'<~Integer> - Id of image
        #     * 'name'<~String> - Name of image
        #     * 'serverId'<~Integer> - Id of server
        def create_image(server_id, options = {})
          data = {
            'image' => {
              'serverId' => server_id
            }
          }
          if options['name']
            data['image']['name'] = options['name']
          end
          request(
            :body     => data.to_json,
            :expects  => 202,
            :method   => 'POST',
            :path     => "images"
          )
        end

      end

      class Mock

        def create_image(server_id, options = {})
          response = Excon::Response.new
          response.status = 202

          now = Time.now
          data = {
            'created'   => now,
            'id'        => 123456,
            'name'      => options['name'] || '',
            'serverId'  => server_id,
            'status'    => 'SAVING',
            'updated'   => now.to_s,
          }

          @data[:last_modified][:images][data['id']] = now
          @data[:images][data['id']] = data
          response.body = { 'image' => data.reject {|key, value| !['id', 'name', 'serverId', 'status', 'updated'].include?(key)} }
          response
        end

      end
    end
  end
end

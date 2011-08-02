module Fog
  module Rackspace
    class Compute
      class Real

        # List public server addresses
        #
        # ==== Parameters
        # * server_id<~Integer> - Id of server to list addresses for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'public'<~Array> - Public ip addresses
        def list_public_addresses(server_id)
          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => "servers/#{server_id}/ips/public.json"
          )
        end

      end

      class Mock

        def list_public_addresses(server_id)
          response = Excon::Response.new
          if server = list_servers_detail.body['servers'].detect {|_| _['id'] == server_id}
            response.status = [200, 203][rand(1)]
            response.body = { 'public' => server['addresses']['public'] }
            response
          else
            raise Fog::Rackspace::Compute::NotFound
          end
        end

      end
    end
  end
end

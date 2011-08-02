module Fog
  module Terremark
    module Shared
      module Real

        # Get details for a Network
        #
        # ==== Parameters
        # * network_id<~Integer> - Id of the network to look up
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   FIXME
        def get_network_ips(network_id)
          opts =  {
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetNetworkIps.new,
            :path     => "network/#{network_id}/ipAddresses"
          }
          if self.is_a?(Fog::Terremark::Ecloud::Real)
            opts[:path] = "/extensions/network/#{network_id}/ips"
          end
          request(opts)
        end

      end

      module Mock

        def get_network_ips(network_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end


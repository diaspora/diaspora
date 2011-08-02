module Fog
  module Terremark
    module Shared
      module Real

        # Get details for a public ip
        #
        # ==== Parameters
        # * public_ip_id<~Integer> - Id of public ip to look up
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'PublicIpAddresses'<~Array>
        #       * 'href'<~String> - linke to item
        #       * 'name'<~String> - name of item
        def get_public_ip(public_ip_id)
          opts = {
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::PublicIp.new,
            :path     => "publicIps/#{public_ip_id}"
          }
          if self.class == Fog::Terremark::Ecloud::Real
            opts[:path] = "extensions/publicIp/#{public_ip_id}"
          end
          request(opts)
        end

      end

      module Mock

        def get_public_ip(public_ip_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end

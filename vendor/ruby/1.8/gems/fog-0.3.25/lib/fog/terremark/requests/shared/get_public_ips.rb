module Fog
  module Terremark
    module Shared
      module Real

        # Get list of public ips
        #
        # ==== Parameters
        # * vdc_id<~Integer> - Id of vdc to find public ips for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'PublicIpAddresses'<~Array>
        #       * 'href'<~String> - link to item
        #       * 'name'<~String> - name of item
        def get_public_ips(vdc_id)
          opts = {
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetPublicIps.new,
            :path     => "vdc/#{vdc_id}/publicIps"
          }
          if self.class == Fog::Terremark::Ecloud::Real
            opts[:path] = "extensions/vdc/#{vdc_id}/publicIps"
          end
          request(opts)
        end

      end

      module Mock

        def get_public_ips(vdc_id)
          vdc_id = vdc_id.to_i
          response = Excon::Response.new

          if vdc = @data[:organizations].map { |org| org[:vdcs] }.flatten.detect { |vdc| vdc[:id] == vdc_id }
            body = { "PublicIpAddresses" => [] }
            vdc[:public_ips].each do |ip|
              ip = { "name" => ip[:name],
                     "href" => case self
                                when Fog::Terremark::Ecloud::Mock
                                  "#{@base_url}/extensions/publicIp/#{ip[:id]}"
                                when Fog::Terremark::Vcloud::Mock
                                  "#{@base_url}/PublicIps/#{ip[:id]}"
                                end,
                     "id"   => ip[:id].to_s }
              body["PublicIpAddresses"] << ip
            end
            response.status = 200
            response.body = body
            response.headers = Fog::Terremark::Shared::Mock.headers(response.body,
                              case self
                              when Fog::Terremark::Ecloud::Mock
                                "application/vnd.tmrk.ecloud.publicIpsList+xml"
                              when Fog::Terremark::Vcloud::Mock
                                "application/xml; charset=utf-8"
                              end
            )
          else
            response.status = Fog::Terremark::Shared::Mock.unathorized_status
            response.headers = Fog::Terremark::Shared::Mock.error_headers
          end

          response
        end

      end
    end
  end
end

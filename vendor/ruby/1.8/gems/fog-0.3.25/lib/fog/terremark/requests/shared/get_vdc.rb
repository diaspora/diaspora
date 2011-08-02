module Fog
  module Terremark
    module Shared
      module Real

        # Get details of a vdc
        #
        # ==== Parameters
        # * vdc_id<~Integer> - Id of vdc to lookup
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:

        # FIXME

        #     * 'CatalogItems'<~Array>
        #       * 'href'<~String> - linke to item
        #       * 'name'<~String> - name of item
        #       * 'type'<~String> - type of item
        #     * 'description'<~String> - Description of catalog
        #     * 'name'<~String> - Name of catalog
        def get_vdc(vdc_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetVdc.new,
            :path     => "vdc/#{vdc_id}"
          )
        end

      end

      module Mock

        def get_vdc(vdc_id)
          vdc_id = vdc_id.to_i
          response = Excon::Response.new

          if vdc = @data[:organizations].map { |org| org[:vdcs] }.flatten.detect { |vdc| vdc[:id] == vdc_id }

            body = { "name" => vdc[:name],
                     "href" => "#{@base_url}/vdc/#{vdc[:id]}",
                     "StorageCapacity" => {},
                     "ComputeCapacity" => { "InstantiatedVmsQuota" => {},
                                            "DeployedVmsQuota" => {},
                                            "Cpu" => {},
                                            "Memory" => {} },
                     "ResourceEntities" => [],
                     "AvailableNetworks" => [],
                     "links" => [] }

            case self
            when Fog::Terremark::Ecloud::Mock
              body["StorageCapacity"] = { "Units" => "bytes * 10^9" }
              vdc[:storage].each { |k,v| body["StorageCapacity"][k.to_s.capitalize] = v.to_s }

              body["ComputeCapacity"] = { "InstantiatedVmsQuota" => {"Limit" => "-1", "Used" => "-1"},
                                           "DeployedVmsQuota" => {"Limit" => "-1", "Used" => "-1"},
                                           "Cpu" => { "Units" => "hz * 10^6" },
                                           "Memory" => { "Units" => "bytes * 2^20" } }

              [:cpu, :memory].each do |key|
                vdc[key].each { |k,v| body["ComputeCapacity"][key.to_s.capitalize][k.to_s.capitalize] = v.to_s }
              end

              body["links"] << { "name" => "Public IPs",
                                 "href" => "#{@base_url}/extensions/vdc/#{vdc[:id]}/publicIps",
                                 "rel"  => "down",
                                 "type" => "application/vnd.tmrk.ecloud.publicIpsList+xml" }

              body["links"] << { "name" => "Internet Services",
                                 "href" => "#{@base_url}/extensions/vdc/#{vdc[:id]}/internetServices",
                                 "rel"  => "down",
                                 "type" => "application/vnd.tmrk.ecloud.internetServicesList+xml" }

              body["links"] << { "name" => "Firewall Access List",
                                 "href" => "#{@base_url}/extensions/vdc/#{vdc[:id]}/firewallAcls",
                                 "rel"  => "down",
                                 "type" => "application/vnd.tmrk.ecloud.firewallAclsList+xml" }

            when Fog::Terremark::Vcloud::Mock
              body["links"] << { "name" => "Public IPs",
                                 "href" => "#{@base_url}/vdc/#{vdc[:id]}/publicIps",
                                 "rel"  => "down",
                                 "type" => "application/xml" }

              body["links"] << { "name" => "Internet Services",
                                 "href" => "#{@base_url}/vdc/#{vdc[:id]}/internetServices",
                                 "rel"  => "down",
                                 "type" => "application/xml" }
            end

            vdc[:vms].each do |vm|
              body["ResourceEntities"] << { "name" => vm[:name],
                                            "href" => "#{@base_url}/vapp/#{vm[:id]}",
                                            "type" => "application/vnd.vmware.vcloud.vApp+xml" }
            end

            vdc[:networks].each do |network|
              body["AvailableNetworks"] << { "name" => network[:name],
                                             "href" => "#{@base_url}/network/#{network[:id]}",
                                             "type" => "application/vnd.vmware.vcloud.network+xml" }
            end

            body["links"] << { "name" => vdc[:name],
                               "href" => "#{@base_url}/vdc/#{vdc[:id]}/catalog",
                               "rel"  => "down",
                               "type" => "application/vnd.vmware.vcloud.catalog+xml" }

            response.status = 200
            response.body = body
            response.headers = Fog::Terremark::Shared::Mock.headers(response.body, "application/vnd.vmware.vcloud.org+xml")
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

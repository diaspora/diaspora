module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          # Handled by the main Vcloud get_vdc
        end

        class Mock
          #
          #Based off of:
          #http://support.theenterprisecloud.com/kb/default.asp?id=545&Lang=1&SID=

          def get_vdc(vdc_uri)
            vdc_uri = ensure_unparsed(vdc_uri)

            if vdc = mock_data.vdc_from_href(vdc_uri)
              xml = Builder::XmlMarkup.new
              mock_it 200,
              xml.Vdc(xmlns.merge(:href => vdc.href, :name => vdc.name)) {
                xml.Link(:rel => "down",
                         :href => vdc.catalog.href,
                         :type => "application/vnd.vmware.vcloud.catalog+xml",
                         :name => vdc.catalog.name)
                xml.Link(:rel => "down",
                         :href => vdc.public_ip_collection.href,
                         :type => "application/vnd.tmrk.ecloud.publicIpsList+xml",
                         :name => vdc.public_ip_collection.name)
                xml.Link(:rel => "down",
                         :href => vdc.internet_service_collection.href,
                         :type => "application/vnd.tmrk.ecloud.internetServicesList+xml",
                         :name => vdc.internet_service_collection.name)
                xml.Link(:rel => "down",
                         :href => vdc.firewall_acls.href,
                         :type => "application/vnd.tmrk.ecloud.firewallAclsList+xml",
                         :name => vdc.firewall_acls.name)
                xml.Description("")
                xml.StorageCapacity {
                  xml.Units("bytes * 10^9")
                  xml.Allocated(vdc.storage_allocated)
                  xml.Used(vdc.storage_used)
                }
                xml.ComputeCapacity {
                  xml.Cpu {
                    xml.Units("hz * 10^6")
                    xml.Allocated(vdc.cpu_allocated)
                  }
                  xml.Memory {
                    xml.Units("bytes * 2^20")
                    xml.Allocated(vdc.memory_allocated)
                  }
                  xml.DeployedVmsQuota {
                    xml.Limit("-1")
                    xml.Used("-1")
                  }
                  xml.InstantiatedVmsQuota {
                    xml.Limit("-1")
                    xml.Used("-1")
                  }
                }
                xml.ResourceEntities {
                  vdc.virtual_machines.each do |virtual_machine|
                    xml.ResourceEntity(:href => virtual_machine.href,
                                       :type => "application/vnd.vmware.vcloud.vApp+xml",
                                       :name => virtual_machine.name)
                  end
                }
                xml.AvailableNetworks {
                  vdc.networks.each do |network|
                    xml.Network(:href => network.href,
                                :type => "application/vnd.vmware.vcloud.network+xml",
                                :name => network.name)
                  end
                }
              }, { 'Content-Type' => 'application/vnd.vmware.vcloud.vdc+xml'}
            else
              mock_error 200, "401 Unauthorized"
            end
          end

        end
      end
    end
  end
end


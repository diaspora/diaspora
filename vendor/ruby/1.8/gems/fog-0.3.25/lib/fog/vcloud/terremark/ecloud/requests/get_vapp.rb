module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_vapp
        end

        class Mock
          def return_vapp_as_creating!(name)
            vapps_to_return_as_creating[name] = true
          end

          def vapps_to_return_as_creating
            @vapps_to_return_as_creating ||= {}
          end

          def get_vapp(vapp_uri)
            xml = nil

            if vapp = mock_data.virtual_machine_from_href(vapp_uri)
              if vapps_to_return_as_creating[vapp.name]
                xml = generate_instantiate_vapp_template_response(vapp)
              else
                xml = generate_get_vapp_response(vapp)
              end
            end

            if xml
              mock_it 200, xml, "Content-Type" => "application/vnd.vmware.vcloud.vApp+xml"
            else
              mock_error 200, "401 Unauthorized"
            end
          end

          private

          def generate_get_vapp_response(vapp)
            builder = Builder::XmlMarkup.new
            builder.VApp(xmlns.merge(
                                     :href => vapp.href,
                                     :type => "application/vnd.vmware.vcloud.vApp+xml",
                                     :name => vapp.name,
                                     :status => vapp.status,
                                     :size => vapp.size
                                     )) do
              builder.Link(:rel => "up", :href => vapp._parent.href, :type => "application/vnd.vmware.vcloud.vdc+xml")

              builder.NetworkConnectionSection(:xmlns => "http://schemas.dmtf.org/ovf/envelope/1") do
                builder.NetworkConnection(:Network => "Internal", :xmlns => "http://www.vmware.com/vcloud/v0.8") do
                  builder.IpAddress vapp.ip
                end
              end

              builder.OperatingSystemSection(
                                             "d2p1:id" => 4,
                                             :xmlns => "http://schemas.dmtf.org/ovf/envelope/1",
                                             "xmlns:d2p1" => "http://schemas.dmtf.org/ovf/envelope/1") do
                builder.Info "The kind of installed guest operating system"
                builder.Description "Red Hat Enterprise Linux 5 (64-bit)"
              end

              builder.VirtualHardwareSection(:xmlns => "http://schemas.dmtf.org/ovf/envelope/1") do
                builder.Info
                builder.System
                builder.Item do
                  # CPUs
                  builder.VirtualQuantity vapp.cpus
                  builder.ResourceType 3
                end
                builder.Item do
                  # memory
                  builder.VirtualQuantity vapp.memory
                  builder.ResourceType 4
                end
                builder.Item do
                  # SCSI controller
                  builder.Address 0
                  builder.ResourceType 6
                  builder.InstanceId 3
                end

                # Hard Disks
                vapp.disks.each do |disk|
                  builder.Item do
                    builder.Parent 3
                    builder.VirtualQuantity disk.vcloud_size
                    builder.HostResource disk.vcloud_size
                    builder.ResourceType 17
                    builder.AddressOnParent disk.address
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

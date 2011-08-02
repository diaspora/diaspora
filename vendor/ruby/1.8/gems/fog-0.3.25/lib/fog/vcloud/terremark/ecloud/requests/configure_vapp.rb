module Fog
  class Vcloud
    module Terremark
      class Ecloud
        module Shared
          private

          def validate_vapp_data(vapp_data)
            valid_opts = [:name, :cpus, :memory, :disks]
            unless valid_opts.all? { |opt| vapp_data.keys.include?(opt) }
              raise ArgumentError.new("Required Vapp data missing: #{(valid_opts - vapp_data.keys).map(&:inspect).join(", ")}")
            end
          end
        end

        class Real
          include Shared

          def generate_configure_vapp_request(vapp_uri, vapp_data)
            rasd_xmlns = { "xmlns" => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" }

            xml = Nokogiri::XML(request( :uri => vapp_uri).body)
            xml.root['name'] = vapp_data[:name]

            #cpu
            xml.at("//xmlns:ResourceType[.='3']/..", rasd_xmlns).at('.//xmlns:VirtualQuantity', rasd_xmlns).content = vapp_data[:cpus]

            #memory
            xml.at("//xmlns:ResourceType[.='4']/..", rasd_xmlns).at('.//xmlns:VirtualQuantity', rasd_xmlns).content = vapp_data[:memory]

            #disks
            real_disks = xml.xpath("//xmlns:ResourceType[ .='17']/..", rasd_xmlns)
            real_disk_numbers = real_disks.map { |disk| disk.at('.//xmlns:AddressOnParent', rasd_xmlns).content }
            disk_numbers = vapp_data[:disks].map { |vdisk| vdisk[:number].to_s }

            if vapp_data[:disks].length < real_disks.length
              #Assume we're removing a disk
              remove_disk_numbers = real_disk_numbers - disk_numbers
              remove_disk_numbers.each do |number|
                if result = xml.at("//xmlns:ResourceType[ .='17']/../xmlns:AddressOnParent[.='#{number}']/..", rasd_xmlns)
                  result.remove
                end
              end
            elsif vapp_data[:disks].length > real_disks.length
              add_disk_numbers = disk_numbers - real_disk_numbers

              add_disk_numbers.each do |number|
                new_disk = real_disks.first.dup
                new_disk.at('.//xmlns:AddressOnParent', rasd_xmlns).content = -1
                new_disk.at('.//xmlns:VirtualQuantity', rasd_xmlns).content = vapp_data[:disks].detect { |disk| disk[:number].to_s == number.to_s }[:size]
                real_disks.first.parent << new_disk
              end
            end

            #puts xml.root.to_s
            xml.root.to_s

            #builder = Builder::XmlMarkup.new
            #builder.Vapp(:href => vapp_uri.to_s,
            #             :type => 'application/vnd.vmware.vcloud.vApp+xml',
            #             :name => vapp_data[:name],
            #             :status => 2,
            #             :size => 0,
            #             :xmlns => 'http://www.vmware.com/vcloud/v0.8',
            #             :"xmlns:xsi" => 'http://www.w3.org/2001/XMLSchema-instance',
            #             :"xmlns:xsd" => 'http://www.w3.org/2001/XMLSchema') {
            #  #builder.VirtualHardwareSection(:xmlns => 'http://schemas.dmtf.org/ovf/envelope/1') {
            #  builder.Section(:"xsi:type" => "q2:VirtualHardwareSection_Type", :xmlns => "http://schemas.dmtf.org/ovf/envelope/1", :"xmlns:q2" => "http://www.vmware.com/vcloud/v0.8") {
            #    builder.Info('Virtual Hardware')
            #    builder.Item(:xmlns => 'http://schemas.dmtf.org/ovf/envelope/1') {
            #    #builder.Item {
            #      builder.InstanceID(1, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #      builder.ResourceType(3, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #      builder.VirtualQuantity(vapp_data[:cpus], :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #    }
            #    builder.Item(:xmlns => 'http://schemas.dmtf.org/ovf/envelope/1') {
            #    #builder.Item {
            #      builder.InstanceID(2, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #      builder.ResourceType(4, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #      builder.VirtualQuantity(vapp_data[:memory], :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #    }
            #    vapp_data[:disks].each do |disk_data|
            #      #builder.Item(:xmlns => 'http://schemas.dmtf.org/ovf/envelope/1') {
            #      builder.Item {
            #        builder.AddressOnParent(disk_data[:number], :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #        builder.HostResource(disk_data[:resource], :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #        builder.InstanceID(9, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #        builder.ResourceType(17, :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #        builder.VirtualQuantity(disk_data[:size], :xmlns => 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData')
            #      }
            #    end
            #
            #  }
            #}
          end

          def configure_vapp(vapp_uri, vapp_data)
            validate_vapp_data(vapp_data)

            request(
              :body     => generate_configure_vapp_request(vapp_uri, vapp_data),
              :expects  => 202,
              :headers  => {'Content-Type' => 'application/vnd.vmware.vcloud.vApp+xml' },
              :method   => 'PUT',
              :uri      => vapp_uri,
              :parse    => true
            )
          end

        end

        class Mock
          include Shared

          def configure_vapp(vapp_uri, vapp_data)
            validate_vapp_data(vapp_data)

            if vapp = mock_data.virtual_machine_from_href(vapp_uri)
              vapp_data.each do |key, value|
                case key
                when :cpus, :memory
                  vapp[key] = value
                when :disks
                  addresses_to_delete = vapp.disks.map {|d| d.address } - value.map {|d| d[:number] }
                  addresses_to_delete.each do |address_to_delete|
                    vapp.disks.delete(vapp.disks.at_address(address_to_delete))
                  end

                  current_addresses = vapp.disks.map {|d| d.address }
                  disks_to_add = value.find_all {|d| !current_addresses.include?(d[:number]) }
                  disks_to_add.each do |disk_to_add|
                    vapp.disks << MockVirtualMachineDisk.new(:size => disk_to_add[:size] / 1024, :address => disk_to_add[:number])
                  end
                end
              end

              mock_it 200, '', { "Location" => mock_data.base_url + "/some_tasks/1234" }
            else
              mock_error 200, "401 Unauthorized"
            end
          end
        end
      end
    end
  end
end


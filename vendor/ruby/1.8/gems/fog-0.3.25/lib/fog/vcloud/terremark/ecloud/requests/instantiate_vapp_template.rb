module Fog
  class Vcloud
    module Terremark
      class Ecloud
        module Shared
          private

          def validate_instantiate_vapp_template_options(catalog_item_uri, options)
            valid_opts = [:name, :vdc_uri, :network_uri, :cpus, :memory, :row, :group]
            unless valid_opts.all? { |opt| options.keys.include?(opt) }
              raise ArgumentError.new("Required data missing: #{(valid_opts - options.keys).map(&:inspect).join(", ")}")
            end

            # Figure out the template_uri
            catalog_item = get_catalog_item( catalog_item_uri ).body
            catalog_item[:Entity] = [ catalog_item[:Entity] ] if catalog_item[:Entity].is_a?(Hash)
            catalog_item[:Link] = [ catalog_item[:Link] ] if catalog_item[:Link].is_a?(Hash)

            options[:template_uri] = begin
               catalog_item[:Entity].detect { |entity| entity[:type] == "application/vnd.vmware.vcloud.vAppTemplate+xml" }[:href]
            rescue
              raise RuntimeError.new("Unable to locate template uri for #{catalog_item_uri}")
            end

            customization_options = begin
                customization_href = catalog_item[:Link].detect { |link| link[:type] == "application/vnd.tmrk.ecloud.catalogItemCustomizationParameters+xml" }[:href]
                get_customization_options( customization_href ).body
            rescue
              raise RuntimeError.new("Unable to get customization options for #{catalog_item_uri}")
            end

            # Check to see if we can set the password
            if options[:password] and customization_options[:CustomizePassword] == "false"
              raise ArgumentError.new("This catalog item (#{catalog_item_uri}) does not allow setting a password.")
            end

            # According to the docs if CustomizePassword is "true" then we NEED to set a password
            if customization_options[:CustomizePassword] == "true" and ( options[:password].nil? or options[:password].empty? )
              raise ArgumentError.new("This catalog item (#{catalog_item_uri}) requires a :password to instantiate.")
            end
          end

          def generate_instantiate_vapp_template_request(options)
            xml = Builder::XmlMarkup.new
            xml.InstantiateVAppTemplateParams(xmlns.merge!(:name => options[:name], :"xml:lang" => "en")) {
              xml.VAppTemplate(:href => options[:template_uri])
              xml.InstantiationParams {
                xml.ProductSection( :"xmlns:q1" => "http://www.vmware.com/vcloud/v0.8", :"xmlns:ovf" => "http://schemas.dmtf.org/ovf/envelope/1") {
                  if options[:password]
                    xml.Property( :xmlns => "http://schemas.dmtf.org/ovf/envelope/1", :"ovf:key" => "password", :"ovf:value" => options[:password] )
                  end
                  xml.Property( :xmlns => "http://schemas.dmtf.org/ovf/envelope/1", :"ovf:key" => "row", :"ovf:value" => options[:row] )
                  xml.Property( :xmlns => "http://schemas.dmtf.org/ovf/envelope/1", :"ovf:key" => "group", :"ovf:value" => options[:group] )
                }
                xml.VirtualHardwareSection( :"xmlns:q1" => "http://www.vmware.com/vcloud/v0.8" ) {
                  # # of CPUS
                  xml.Item( :xmlns => "http://schemas.dmtf.org/ovf/envelope/1" ) {
                    xml.InstanceID(1, :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                    xml.ResourceType(3, :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                    xml.VirtualQuantity(options[:cpus], :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                  }
                  # Memory
                  xml.Item( :xmlns => "http://schemas.dmtf.org/ovf/envelope/1" ) {
                    xml.InstanceID(2, :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                    xml.ResourceType(4, :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                    xml.VirtualQuantity(options[:memory], :xmlns => "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                  }
                }
                xml.NetworkConfigSection {
                  xml.NetworkConfig {
                    xml.NetworkAssociation( :href => options[:network_uri] )
                  }
                }
              }
            }
          end
        end

        class Real
          include Shared

          def instantiate_vapp_template(catalog_item_uri, options = {})
            validate_instantiate_vapp_template_options(catalog_item_uri, options)

            request(
              :body     => generate_instantiate_vapp_template_request(options),
              :expects  => 200,
              :headers  => {'Content-Type' => 'application/vnd.vmware.vcloud.instantiateVAppTemplateParams+xml'},
              :method   => 'POST',
              :uri      => options[:vdc_uri] + '/action/instantiatevAppTemplate',
              :parse    => true
            )
          end
        end

        class Mock
          include Shared

          #
          # Based on
          # http://support.theenterprisecloud.com/kb/default.asp?id=554&Lang=1&SID=
          #

          def instantiate_vapp_template(catalog_item_uri, options = {})
            validate_instantiate_vapp_template_options(catalog_item_uri, options)
            catalog_item = mock_data.catalog_item_from_href(catalog_item_uri)

            xml = nil
            if vdc = mock_data.vdc_from_href(options[:vdc_uri])
              if network = mock_data.network_from_href(options[:network_uri])
                new_vm = MockVirtualMachine.new({ :name => options[:name], :ip => network.random_ip, :cpus => options[:cpus], :memory => options[:memory] }, vdc)
                new_vm.disks.push(*catalog_item.disks.dup)
                vdc.virtual_machines << new_vm

                xml = generate_instantiate_vapp_template_response(new_vm)
              end
            end

            if xml
              mock_it 200, xml, {'Content-Type' => 'application/xml'}
            else
              mock_error 200, "401 Unauthorized"
            end
          end

          private

          def generate_instantiate_vapp_template_response(vapp)
            builder = Builder::XmlMarkup.new
            builder.VApp(xmlns.merge(
                                     :href => vapp.href,
                                     :type => "application/vnd.vmware.vcloud.vApp+xml",
                                     :name => vapp.name,
                                     :status => 0,
                                     :size => 4
                                     )) {
              builder.Link(:rel => "up", :href => vapp._parent.href, :type => "application/vnd.vmware.vcloud.vdc+xml")
            }
          end
        end
      end
    end
  end
end

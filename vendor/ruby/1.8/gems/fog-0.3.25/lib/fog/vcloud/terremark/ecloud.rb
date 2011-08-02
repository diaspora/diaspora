module Fog
  class Vcloud
    module Terremark
      class Ecloud < Fog::Vcloud

        model_path 'fog/vcloud/terremark/ecloud/models'
        model :catalog_item
        model :catalog
        model :firewall_acl
        collection :firewall_acls
        model :internet_service
        collection :internet_services
        model :ip
        collection :ips
        model :network
        collection :networks
        model :node
        collection :nodes
        model :public_ip
        collection :public_ips
        model :server
        collection :servers
        model :task
        collection :tasks
        model :vdc
        collection :vdcs

        request_path 'fog/vcloud/terremark/ecloud/requests'
        request :add_internet_service
        request :add_node
        request :clone_vapp
        request :configure_internet_service
        request :configure_network
        request :configure_network_ip
        request :configure_node
        request :configure_vapp
        request :delete_internet_service
        request :delete_node
        request :delete_vapp
        request :get_catalog
        request :get_catalog_item
        request :get_customization_options
        request :get_firewall_acls
        request :get_firewall_acl
        request :get_internet_services
        request :get_network
        request :get_network_ip
        request :get_network_ips
        request :get_network_extensions
        request :get_node
        request :get_nodes
        request :get_public_ip
        request :get_public_ips
        request :get_task
        request :get_task_list
        request :get_vapp
        request :get_vapp_template
        request :get_vdc
        request :instantiate_vapp_template
        request :power_off
        request :power_on
        request :power_reset
        request :power_shutdown

        class Mock < Fog::Vcloud::Mock

          def initialize(options={})
          end

          def self.base_url
            "https://fakey.com/api/v0.8b-ext2.3"
          end

          def self.data_reset
            @mock_data = nil
            Fog::Vcloud::Mock.data_reset
          end

          def self.data( base_url = self.base_url )
            @mock_data ||= Fog::Vcloud::Mock.data(base_url).tap do |vcloud_mock_data|
              vcloud_mock_data.versions.clear
              vcloud_mock_data.versions << MockVersion.new(:version => "v0.8b-ext2.3")

              vcloud_mock_data.organizations.detect {|o| o.name == "Boom Inc." }.tap do |mock_organization|
                mock_organization.vdcs.detect {|v| v.name == "Boomstick" }.tap do |mock_vdc|
                  mock_vdc.public_ip_collection.items << MockPublicIp.new(:name => "99.1.2.3").tap do |mock_public_ip|
                    mock_public_ip.internet_service_collection.items << MockPublicIpInternetService.new({
                                                                                                          :protocol => "HTTP",
                                                                                                          :port => 80,
                                                                                                          :name => "Web Site",
                                                                                                          :description => "Web Servers",
                                                                                                          :redirect_url => "http://fakey.com"
                                                                                                        }, mock_public_ip.internet_service_collection
                                                                                                        ).tap do |mock_public_ip_service|
                      mock_public_ip_service.node_collection.items << MockPublicIpInternetServiceNode.new({:ip_address => "1.2.3.5", :name => "Test Node 1", :description => "web 1"}, mock_public_ip_service.node_collection)
                      mock_public_ip_service.node_collection.items << MockPublicIpInternetServiceNode.new({:ip_address => "1.2.3.6", :name => "Test Node 2", :description => "web 2"}, mock_public_ip_service.node_collection)
                      mock_public_ip_service.node_collection.items << MockPublicIpInternetServiceNode.new({:ip_address => "1.2.3.7", :name => "Test Node 3", :description => "web 3"}, mock_public_ip_service.node_collection)
                    end

                    mock_public_ip.internet_service_collection.items << MockPublicIpInternetService.new({
                                                                                                          :protocol => "TCP",
                                                                                                          :port => 7000,
                                                                                                          :name => "An SSH Map",
                                                                                                          :description => "SSH 1"
                                                                                                        }, mock_public_ip.internet_service_collection
                                                                                                        ).tap do |mock_public_ip_service|
                      mock_public_ip_service.node_collection.items << MockPublicIpInternetServiceNode.new({ :ip_address => "1.2.3.5", :port => 22, :name => "SSH", :description => "web ssh" }, mock_public_ip_service.node_collection)
                    end
                  end

                  mock_vdc.public_ip_collection.items << MockPublicIp.new(:name => "99.1.2.4").tap do |mock_public_ip|
                    mock_public_ip.internet_service_collection.items << MockPublicIpInternetService.new({
                                                                                                          :protocol => "HTTP",
                                                                                                          :port => 80,
                                                                                                          :name => "Web Site",
                                                                                                          :description => "Web Servers",
                                                                                                          :redirect_url => "http://fakey.com"
                                                                                                        }, mock_public_ip.internet_service_collection
                                                                                                        )

                    mock_public_ip.internet_service_collection.items << MockPublicIpInternetService.new({
                                                                                                          :protocol => "TCP",
                                                                                                          :port => 7000,
                                                                                                          :name => "An SSH Map",
                                                                                                          :description => "SSH 2"
                                                                                                        }, mock_public_ip.internet_service_collection
                                                                                                        )
                  end

                  mock_vdc.public_ip_collection.items << MockPublicIp.new(:name => "99.1.9.7")
                end

                mock_organization.vdcs.detect {|v| v.name == "Rock-n-Roll" }.tap do |mock_vdc|
                  mock_vdc.public_ip_collection.items << MockPublicIp.new(:name => "99.99.99.99")
                end
              end

              vcloud_mock_data.organizations.each do |organization|
                organization.vdcs.each do |vdc|
                  vdc.networks.each do |network|
                    network[:rnat] = vdc.public_ip_collection.items.first.name
                  end
                  vdc.virtual_machines.each do |virtual_machine|
                    virtual_machine.disks << MockVirtualMachineDisk.new(:size => 25 * 1024)
                    virtual_machine.disks << MockVirtualMachineDisk.new(:size => 50 * 1024)
                  end
                end
              end
            end
          end

          def ecloud_xmlns
            { :xmlns => "urn:tmrk:eCloudExtensions-2.3", :"xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance" }
          end

          def mock_data
            Fog::Vcloud::Terremark::Ecloud::Mock.data
          end
        end

        class Real < Fog::Vcloud::Real

          def supporting_versions
            ["v0.8b-ext2.3", "0.8b-ext2.3"]
          end

        end

      end
    end
  end
end

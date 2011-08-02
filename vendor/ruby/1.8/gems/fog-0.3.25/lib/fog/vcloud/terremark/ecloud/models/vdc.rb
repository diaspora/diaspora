module Fog
  class Vcloud
    module Terremark
      class Ecloud
        class Vdc < Fog::Vcloud::Model

          identity :href

          ignore_attributes :xmlns, :xmlns_xsi, :xmlns_xsd

          attribute :name
          attribute :type
          attribute :description, :aliases => :Description
          attribute :other_links, :aliases => :Link
          attribute :compute_capacity, :aliases => :ComputeCapacity
          attribute :storage_capacity, :aliases => :StorageCapacity
          attribute :available_networks, :aliases => :AvailableNetworks, :squash => :Network
          attribute :resource_entities, :aliases => :ResourceEntities, :squash => :ResourceEntity
          attribute :deployed_vm_quota
          attribute :instantiated_vm_quota

          def public_ips
            @public_ips ||= collection_based_on_type("application/vnd.tmrk.ecloud.publicIpsList+xml")
          end

          def internet_services
            @internet_services ||= collection_based_on_type("application/vnd.tmrk.ecloud.internetServicesList+xml")
          end

          def networks
            @networks ||= Fog::Vcloud::Terremark::Ecloud::Networks.
              new( :connection => connection,
                   :href => href )
          end

          def servers
            @servers ||= Fog::Vcloud::Terremark::Ecloud::Servers.
              new( :connection => connection,
                   :href => href )
          end

          def tasks
            @tasks ||= Fog::Vcloud::Terremark::Ecloud::Tasks.
              new( :connection => connection,
                   :href => href + "/tasksList" )
          end

          def catalog
            @catalog ||= collection_based_on_type("application/vnd.vmware.vcloud.catalog+xml")
          end

          def firewall_acls
            @firewall_acls ||= collection_based_on_type("application/vnd.tmrk.ecloud.firewallAclsList+xml")
          end

          private

          def collection_based_on_type(type)
            load_unless_loaded!
            if link = other_links.detect { |link| link[:type] == type }
              case type
              when "application/vnd.tmrk.ecloud.publicIpsList+xml"
                Fog::Vcloud::Terremark::Ecloud::PublicIps
              when "application/vnd.tmrk.ecloud.internetServicesList+xml"
                Fog::Vcloud::Terremark::Ecloud::InternetServices
              when "application/vnd.vmware.vcloud.catalog+xml"
                Fog::Vcloud::Terremark::Ecloud::Catalog
              when "application/vnd.tmrk.ecloud.firewallAclsList+xml"
                Fog::Vcloud::Terremark::Ecloud::FirewallAcls
              end.new( :connection => connection, :href => link[:href] )
            else
              [ ]
            end
          end
        end
      end
    end
  end
end

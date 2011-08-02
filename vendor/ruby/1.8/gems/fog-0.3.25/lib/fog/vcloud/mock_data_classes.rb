require "ipaddr"

class IPAddr
  def mask
    _to_string(@mask_addr)
  end
end

module Fog
  class Vcloud
    module MockDataClasses
      class Base < Hash
        def self.base_url=(url)
          @base_url = url
        end

        self.base_url = "http://vcloud.example.com"

        def self.base_url
          @base_url
        end

        def first
          raise "Don't do this"
        end

        def last
          raise "Don't do this"
        end

        def initialize(data = {}, parent = nil)
          @parent = parent

          replace(data)
        end

        def _parent
          @parent
        end

        def base_url
          Base.base_url
        end

        def href
          [base_url, self.class.name.split("::").last, object_id].join("/")
        end

        def inspect
          "<#{self.class.name} #{object_id} data=#{super} method_data=#{method_data.inspect}>"
        end

        private

        def unique_methods
          (public_methods - self.class.superclass.public_instance_methods).reject {|m| m.to_s =~ /!$/ }
        end

        def method_data
          (unique_methods + [:href]).sort_by(&:to_s).find_all {|m| method(m).arity == 0 }.inject({}) {|md, m| md.update(m => send(m)) }
        end
      end

      class MockData < Base
        def versions
          @versions ||= []
        end

        def organizations
          @organizations ||= []
        end

        def organization_from_href(href)
          find_href_in(href, organizations)
        end

        def all_vdcs
          organizations.map(&:vdcs).flatten
        end

        def vdc_from_href(href)
          find_href_in(href, all_vdcs)
        end

        def all_catalogs
          all_vdcs.map(&:catalog).flatten
        end

        def catalog_from_href(href)
          find_href_in(href, all_catalogs)
        end

        def all_catalog_items
          all_catalogs.map(&:items).flatten
        end

        def catalog_item_from_href(href)
          find_href_in(href, all_catalog_items)
        end

        def all_virtual_machines
          all_vdcs.map(&:virtual_machines).flatten
        end

        def virtual_machine_from_href(href)
          find_href_prefixed_in(href, all_virtual_machines)
        end


        def all_networks
          all_vdcs.map(&:networks).flatten
        end

        def network_from_href(href)
          find_href_in(href, all_networks)
        end

        def all_network_extensions
          all_networks.map(&:extensions).flatten
        end

        def network_extension_from_href(href)
          find_href_in(href, all_network_extensions)
        end

        def all_vdc_internet_service_collections
          all_vdcs.map(&:internet_service_collection).flatten
        end

        def vdc_internet_service_collection_from_href(href)
          find_href_in(href, all_vdc_internet_service_collections)
        end

        def all_public_ip_collections
          all_vdcs.map {|v| v.public_ip_collection }.flatten
        end

        def public_ip_collection_from_href(href)
          find_href_in(href, all_public_ip_collections)
        end

        def all_public_ips
          all_public_ip_collections.map(&:items).flatten
        end

        def public_ip_from_href(href)
          find_href_in(href, all_public_ips)
        end

        def all_public_ip_internet_service_collections
          all_public_ips.map(&:internet_service_collection).flatten
        end

        def public_ip_internet_service_collection_from_href(href)
          find_href_in(href, all_public_ip_internet_service_collections)
        end

        def all_public_ip_internet_services
          all_public_ip_internet_service_collections.map(&:items).flatten
        end

        def public_ip_internet_service_from_href(href)
          find_href_in(href, all_public_ip_internet_services)
        end

        def all_public_ip_internet_service_node_collections
          all_public_ip_internet_services.map(&:node_collection).flatten
        end

        def public_ip_internet_service_node_collection_from_href(href)
          find_href_in(href, all_public_ip_internet_service_node_collections)
        end

        def all_public_ip_internet_service_nodes
          all_public_ip_internet_service_node_collections.map(&:items).flatten
        end

        def public_ip_internet_service_node_from_href(href)
          find_href_in(href, all_public_ip_internet_service_nodes)
        end

        def all_network_ip_collections
          all_networks.map(&:ip_collection)
        end

        def network_ip_collection_from_href(href)
          find_href_in(href, all_network_ip_collections)
        end

        def all_network_ips
          all_network_ip_collections.map {|c| c.items.values }.flatten
        end

        def network_ip_from_href(href)
          find_href_in(href, all_network_ips)
        end

        private

        def find_href_in(href, objects)
          objects.detect {|o| o.href == href }
        end

        def find_href_prefixed_in(href, objects)
          objects.detect {|o| href =~ %r{^#{o.href}($|/)} }
        end
      end

      class MockVersion < Base
        def version
          self[:version]
        end

        def supported
          !!self[:supported]
        end

        def login_url
          href
        end
      end

      class MockOrganization < Base
        def name
          self[:name]
        end

        def vdcs
          @vdcs ||= []
        end
      end

      class MockVdc < Base
        def name
          self[:name]
        end

        def storage_allocated
          self[:storage_allocated] || 200
        end

        def storage_used
          self[:storage_used] || 105
        end

        def cpu_allocated
          self[:cpu_allocated] || 10000
        end

        def memory_allocated
          self[:memory_allocated] || 20480
        end

        def catalog
          @catalog ||= MockCatalog.new({}, self)
        end

        def networks
          @networks ||= []
        end

        def virtual_machines
          @virtual_machines ||= []
        end

        def task_list
          @task_list ||= MockTaskList.new({}, self)
        end

        # for TM eCloud, should probably be subclassed
        def public_ip_collection
          @public_ip_collection ||= MockPublicIps.new({}, self)
        end

        def internet_service_collection
          @internet_service_collection ||= MockVdcInternetServices.new({}, self)
        end

        def firewall_acls
          @firewall_acls ||= MockFirewallAcls.new({}, self)
        end
      end

      class MockTaskList < Base
        def name
          self[:name] || "Tasks List"
        end
      end

      class MockCatalog < Base
        def name
          self[:name] || "Catalog"
        end

        def items
          @items ||= []
        end
      end

      class MockCatalogItem < Base
        def name
          self[:name]
        end

        def disks
          @disks ||= MockVirtualMachineDisks.new(self)
        end

        def customization
          @customization ||= MockCatalogItemCustomization.new({}, self)
        end

        def vapp_template
          @vapp_template ||= MockCatalogItemVappTemplate.new({ :name => name }, self)
        end
      end

      class MockCatalogItemCustomization < Base
        def name
          self[:name] || "Customization Options"
        end
      end

      class MockCatalogItemVappTemplate < Base
        def name
          self[:name]
        end
      end

      class MockNetwork < Base
        def name
          self[:name] || subnet
        end

        def subnet
          self[:subnet]
        end

        def gateway
          self[:gateway] || subnet_ips[1]
        end

        def netmask
          self[:netmask] || subnet_ipaddr.mask
        end

        def dns
          "8.8.8.8"
        end

        def features
          [
           { :type => :FenceMode, :value => "isolated" }
          ]
        end

        def ip_collection
          @ip_collection ||= MockNetworkIps.new({}, self)
        end

        def extensions
          @extensions ||= MockNetworkExtensions.new({}, self)
        end

        def random_ip
          usable_subnet_ips[rand(usable_subnet_ips.length)]
        end

        # for TM eCloud. should probably be a subclass
        def rnat
          self[:rnat]
        end

        def usable_subnet_ips
          subnet_ips[3..-2]
        end

        def address
          subnet_ips.first
        end

        def broadcast
          subnet_ips.last
        end

        private

        def subnet_ipaddr
          @ipaddr ||= IPAddr.new(subnet)
        end

        def subnet_ips
          subnet_ipaddr.to_range.to_a.map(&:to_s)
        end
      end

      class MockNetworkIps < Base
        def items
          @items ||= _parent.usable_subnet_ips.inject({}) do |out, subnet_ip|
            out.update(subnet_ip => MockNetworkIp.new({ :ip => subnet_ip }, self))
          end
        end

        def ordered_ips
          items.values.sort_by {|i| i.ip.split(".").map(&:to_i) }
        end

        def name
          "IP Addresses"
        end
      end

      class MockNetworkIp < Base
        def name
          self[:name] || ip
        end

        def ip
          self[:ip]
        end

        def used_by
          self[:used_by] || _parent._parent._parent.virtual_machines.detect {|v| v.ip == ip }
        end

        def status
          if used_by
            "Assigned"
          else
            "Available"
          end
        end

        def rnat
          self[:rnat] || _parent._parent.rnat
        end
      end

      class MockNetworkExtensions < Base
        def name
          _parent.name
        end

        def gateway
          _parent.gateway
        end

        def broadcast
          _parent.broadcast
        end

        def address
          _parent.address
        end

        def rnat
          _parent.rnat
        end
      end

      class MockVirtualMachine < Base
        def name
          self[:name]
        end

        def ip
          self[:ip]
        end

        def cpus
          self[:cpus] || 1
        end

        def memory
          self[:memory] || 1024
        end

        def disks
          @disks ||= MockVirtualMachineDisks.new(self)
        end

        def status
          self[:status] || 2
        end

        def power_off!
          self[:status] = 2
        end

        def power_on!
          self[:status] = 4
        end

        def size
          disks.inject(0) {|s, d| s + d.vcloud_size }
        end

        # from fog ecloud server's _compose_vapp_data
        def to_configure_vapp_hash
          {
            :name   => name,
            :cpus   => cpus,
            :memory => memory,
            :disks  => disks.map {|d| { :number => d.address.to_s, :size => d.vcloud_size, :resource => d.vcloud_size.to_s } }
          }
        end

        def href(purpose = :base)
          case purpose
          when :base
            super()
          when :power_on
            super() + "/power/action/powerOn"
          when :power_off
            super() + "/power/action/powerOff"
          end
        end
      end

      class MockVirtualMachineDisks < Array
        def initialize(parent = nil)
          @parent = parent
        end

        def _parent
          @parent
        end

        def <<(disk)
          next_address = 0
          disk_with_max_address = max {|a, b| a[:address] <=> b[:address] }
          disk_with_max_address && next_address = disk_with_max_address.address + 1
          disk[:address] ||= next_address

          super(disk)

          if (addresses = map {|d| d.address }).uniq.size != size
            raise "Duplicate disk address in: #{addresses.inspect} (#{size})"
          end

          sort! {|a, b| a.address <=> b.address }
          self
        end

        def at_address(address)
          detect {|d| d.address == address }
        end
      end

      class MockVirtualMachineDisk < Base
        def size
          self[:size].to_i
        end

        def vcloud_size
          # kilobytes
          size * 1024
        end

        def address
          self[:address].to_i
        end
      end

      # for Terremark eCloud

      class MockVdcInternetServices < Base
        def href
          _parent.href + "/internetServices"
        end

        def name
          "Internet Services"
        end

        def items
          _parent.public_ip_collection.items.inject([]) do |services, public_ip|
            services + public_ip.internet_service_collection.items
          end
        end
      end

      class MockFirewallAcls < Base
        def name
          "Firewall Access List"
        end
      end

      class MockPublicIps < Base
        def name
          self[:name] || "Public IPs"
        end

        def items
          @items ||= []
        end
      end

      class MockPublicIp < Base
        def name
          self[:name]
        end

        def internet_service_collection
          @internet_service_collection ||= MockPublicIpInternetServices.new({}, self)
        end
      end

      class MockPublicIpInternetServices < Base
        def href
          _parent.href + "/internetServices"
        end

        def items
          @items ||= []
        end
      end

      class MockPublicIpInternetService < Base
        def name
          self[:name] || "Public IP Service #{object_id}"
        end

        def description
          self[:description] || "Description for Public IP Service #{name}"
        end

        def protocol
          self[:protocol]
        end

        def port
          self[:port]
        end

        def enabled
          !!self[:enabled]
        end

        def redirect_url
          self[:redirect_url]
        end

        def timeout
          self[:timeout] || 2
        end

        def node_collection
          @node_collection ||= MockPublicIpInternetServiceNodes.new({}, self)
        end

        def monitor
          nil
        end
      end

      class MockPublicIpInternetServiceNodes < Base
        def href
          _parent.href + "/nodeServices"
        end

        def items
          @items ||= [].tap do |node_array|
            node_array.instance_variable_set("@default_port", _parent.port)

            def node_array.<<(node)
              node[:port] ||= @default_port
              super
            end
          end
        end
      end

      class MockPublicIpInternetServiceNode < Base
        def ip_address
          self[:ip_address]
        end

        def name
          self[:name] || "Public IP Service Node #{object_id}"
        end

        def description
          self[:description] || "Description for Public IP Service Node #{name}"
        end

        def port
          self[:port]
        end

        def enabled
          self[:enabled].to_s.downcase != "false"
        end

        def enabled=(new_value)
          self[:enabled] = new_value
        end
      end
    end
  end
end

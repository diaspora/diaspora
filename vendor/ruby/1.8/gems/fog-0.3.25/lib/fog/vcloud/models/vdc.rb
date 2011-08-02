module Fog
  class Vcloud
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
      attribute :enabled, :aliases => :IsEnabled
      attribute :vm_quota, :aliases => :VmQuota
      attribute :nic_quota, :aliases => :NicQuota
      attribute :network_quota, :aliases => :NetworkQuota
      attribute :allocation_model, :aliases => :AllocationModel

    end

  end
end

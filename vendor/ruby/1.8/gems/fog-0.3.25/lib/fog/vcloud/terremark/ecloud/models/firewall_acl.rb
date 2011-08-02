module Fog
  class Vcloud
    module Terremark
      class Ecloud
        class FirewallAcl < Fog::Vcloud::Model

          identity :href, :aliases => :Href

          ignore_attributes :xmlns, :xmlns_i

          attribute :name, :aliases => :Name
          attribute :id, :aliases => :Id
          attribute :protocol, :aliases => :Protocol
          attribute :source, :aliases => :Source
          attribute :destination, :aliases => :Destination
          attribute :permission, :aliases => :Permission
          attribute :port_start, :aliases => :PortStart
          attribute :port_end, :aliases => :PortEnd
          attribute :port_type, :aliases => :PortType
          attribute :type, :aliases => :Type

        end
      end
    end
  end
end



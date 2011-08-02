require 'fog/vcloud/terremark/ecloud/models/network'

module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Networks < Fog::Vcloud::Collection

          undef_method :create

          model Fog::Vcloud::Terremark::Ecloud::Network

          attribute :href

          def all
            check_href!("Vdc")
            if data = connection.get_vdc(href).body[:AvailableNetworks][:Network]
              load(data)
            end
          end

          def get(uri)
            if data = connection.get_network(uri)
              new(data.body)
            end
            rescue Fog::Errors::NotFound
            nil
          end

        end
      end
    end
  end
end


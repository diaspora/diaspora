module Fog
  class Vcloud
    module Terremark
      class Ecloud
        class Node < Fog::Vcloud::Model

          identity :href, :aliases => :Href

          ignore_attributes :xmlns, :xmlns_i
          
          attribute :ip_address, :aliases => :IpAddress
          attribute :description, :aliases => :Description
          attribute :name, :aliases => :Name
          attribute :port, :aliases => :Port
          attribute :enabled, :aliases => :Enabled
          attribute :id, :aliases => :Id

          def delete
            requires :href

            connection.delete_node( href )
          end

          def save
            if new_record?
              result = connection.add_node( collection.href, _compose_node_data )
              merge_attributes(result.body)
            else
              connection.configure_node( href, _compose_node_data )
            end
          end

          private

          def _compose_node_data
            node_data = {}
            self.class.attributes.select{ |attribute| !send(attribute).nil? }.each { |attribute| node_data[attribute] = send(attribute).to_s }
            node_data
          end

        end
      end
    end
  end
end



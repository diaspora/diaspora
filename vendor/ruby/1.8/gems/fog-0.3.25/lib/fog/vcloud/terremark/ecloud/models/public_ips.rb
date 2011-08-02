require 'fog/vcloud/terremark/ecloud/models/public_ip'

module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class PublicIps < Fog::Vcloud::Collection

          undef_method :create

          attribute :href, :aliases => :Href

          model Fog::Vcloud::Terremark::Ecloud::PublicIp

          #get_request :get_public_ip
          #vcloud_type "application/vnd.tmrk.ecloud.publicIp+xml"
          #all_request lambda { |public_ips| public_ips.connection.get_public_ips(public_ips.href) }

          def all
            check_href!(:message => "the Public Ips href of the Vdc you want to enumerate")
            if data = connection.get_public_ips(href).body[:PublicIPAddress]
              load(data)
            end
          end

          def get(uri)
            if data = connection.get_public_ip(uri)
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

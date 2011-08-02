require 'fog/vcloud/terremark/ecloud/models/internet_service'

module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class InternetServices < Fog::Vcloud::Collection

          model Fog::Vcloud::Terremark::Ecloud::InternetService

          attribute :href, :aliases => :Href

          def all
            check_href! :message => "the Internet Services for the Vdc you want to enumerate"
            if data = connection.get_internet_services(href).body[:InternetService]
              load(data)
            end
          end

          # Optimize later, no need to get_internet_services again?
          def get(uri)
            internet_services = connection.get_internet_services(href).body[:InternetService]
            internet_services = [ internet_services ] if internet_services.is_a?(Hash)
            if data = internet_services.detect { |service| service[:Href] == uri }
              new(data)
            end
          rescue Fog::Errors::NotFound
            nil
          end

        end
      end
    end
  end
end

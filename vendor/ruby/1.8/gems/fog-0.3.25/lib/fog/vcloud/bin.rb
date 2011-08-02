module Vcloud
  class << self

    def services
      if Fog.credentials.has_key?(:vcloud)
        Fog.credentials[:vcloud].keys.sort { |a,b| a.to_s <=> b.to_s }
      else
        []
      end
    end

    def registered_services
      Vcloud.services.map { |service| ":" << service.to_s }.join(", ")
    end

    def complete_service_options?(service)
      if Fog.credentials.has_key?(:vcloud)
        if Fog.credentials[:vcloud].has_key?(service)
          service = Fog.credentials[:vcloud][service]
          if Fog::Vcloud.requirements.all? { |option| service.has_key?(option) }
            return true
          end
        end
      end
      false
    end

    if Vcloud.services.any? && Vcloud.services.all? { |service| Vcloud.complete_service_options?(service) }

      def initialized?
        true
      end

      def startup_notice
        Formatador.display_line("You have access to the following Vcloud services: #{Vcloud.registered_services}.")
      end

      def [](service)
        @@connections ||= Hash.new do |hash, key|
          if credentials = Fog.credentials[:vcloud][key]
            hash[key] = eval(credentials[:module]).new(credentials)
          else
            raise ArgumentError.new("Unregistered service: :#{key}. Registered services are: #{Vcloud.registered_services}")
          end
        end
        @@connections[service]
      end

    else

      def initialized?
        false
      end

    end
  end
end

class Terremark < Fog::Bin
  class << self

    def available?
      Fog::Terremark::ECLOUD_OPTIONS.all? {|requirement| Fog.credentials.include?(requirement)} ||
      Fog::Terremark::VCLOUD_OPTIONS.all? {|requirement| Fog.credentials.include?(requirement)}
    end

    def terremark_service(service)
      case service
      when :ecloud
        Fog::Terremark::Ecloud
      when :vcloud
        Fog::Terremark::Vcloud
      else
        raise "Unsupported Terremark Service"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        credentials = Fog.credentials.reject do |k,v|
          case key
          when :ecloud
            !Fog::Terremark::ECLOUD_OPTIONS.include?(k)
          when :vcloud
            !Fog::Terremark::VCLOUD_OPTIONS.include?(k)
          end
        end
        hash[key] = terremark_service(key).new(credentials)
      end
      @@connections[service]
    end

  end
end

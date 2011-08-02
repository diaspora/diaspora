class Google < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :storage
          Fog::Google::Storage.new
        end
      end
      @@connections[service]
    end

    def services
      [:storage]
    end

  end

end

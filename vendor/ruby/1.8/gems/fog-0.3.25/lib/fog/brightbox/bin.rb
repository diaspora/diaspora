class Brightbox < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Brightbox::Compute.new
        end
      end
      @@connections[service]
    end

    def services
      [:compute]
    end

    def account
      @@connections[:compute].account
    end

  end
end

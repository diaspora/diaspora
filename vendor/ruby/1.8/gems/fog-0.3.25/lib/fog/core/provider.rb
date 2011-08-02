module Fog
  module Provider

    def service_path(new_path)
      @service_path = new_path
    end

    def service(new_service)
      services << new_service
      require File.join(@service_path, new_service.to_s)
    end

    def services
      @services ||= []
    end

  end
end

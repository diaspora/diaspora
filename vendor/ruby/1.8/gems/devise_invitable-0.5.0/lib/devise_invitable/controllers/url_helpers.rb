module DeviseInvitable
  module Controllers
    module UrlHelpers
      [:path, :url].each do |path_or_url|
        [nil, :new_, :accept_].each do |action|
          class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
            def #{action}invitation_#{path_or_url}(resource, *args)
              resource = case resource
                when Symbol, String
                  resource
                when Class
                  resource.name.underscore
                else
                  resource.class.name.underscore
              end
              
              send("#{action}\#{resource}_invitation_#{path_or_url}", *args)
            end
          URL_HELPERS
        end
      end
    end
  end
end

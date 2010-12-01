module Jammit

  # Rails 2.x routing module. Rails 3.x routes are in rails/routes.rb.
  module Routes

    # Jammit uses a single route in order to slow down Rails' routing speed
    # by the absolute minimum. In your config/routes.rb file, call:
    #   Jammit::Routes.draw(map)
    # Passing in the routing "map" object.
    def self.draw(map)
      map.jammit "/#{Jammit.package_path}/:package.:extension", {
        :controller => 'jammit',
        :action => 'package',
        :requirements => {
          # A hack to allow extension to include "."
          :extension => /.+/
        }
      }
    end

  end

end
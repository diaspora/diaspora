# Rails 3 configuration via Railtie

if defined?(Rails::Railtie)
  module Jammit
    class Railtie < Rails::Railtie

      initializer :jammit_routes do |app|
        # Add a Jammit route for the reloader.
        app.routes_reloader.paths << File.join(File.dirname(__FILE__), "..", "..", "rails", "routes.rb")
      end

    end
  end
end

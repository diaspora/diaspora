Rails.application.config.middleware.insert_before(Rack::Runtime, Rack::SSL) if EnviromentConfiguration.enforce_ssl?

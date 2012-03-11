Rails.application.config.middleware.insert 0, Rack::Cors do
  allow do
    origins '*'
    resource '/.well-known/host-meta'
    resource '/webfinger'
  end
end

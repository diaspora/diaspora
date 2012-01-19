if EnviromentConfiguration.enforce_ssl?
  Rails.application.config.middleware.insert_before HoptoadNotifier::UserInformer, Rack::SSL
  puts "Rack::SSL is enabled"
end

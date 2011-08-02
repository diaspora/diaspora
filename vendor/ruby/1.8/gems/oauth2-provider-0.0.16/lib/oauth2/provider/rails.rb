require 'oauth2/provider'

module OAuth2::Provider::Rails
  autoload :ControllerAuthentication, 'oauth2/provider/rails/controller_authentication'
  
  class Railtie < Rails::Railtie
    config.oauth2_provider = ActiveSupport::OrderedOptions.new
    config.oauth2_provider.activerecord = ActiveSupport::OrderedOptions.new
    config.oauth2_provider.mongoid = ActiveSupport::OrderedOptions.new

    initializer "oauth2_provider.config" do |app|
      app.config.oauth2_provider.except(:activerecord, :mongoid).each do |k,v|
        OAuth2::Provider.send "#{k}=", v
      end

      app.config.oauth2_provider.activerecord.each do |k, v|
        OAuth2::Provider::Models::ActiveRecord.send "#{k}=", v
      end

      app.config.oauth2_provider.mongoid.each do |k, v|
        OAuth2::Provider::Models::Mongoid.send "#{k}=", v
      end

      OAuth2::Provider.activate
    end

    initializer "oauth2_provider.initialize_controller" do |app|
      ActionController::Base.module_eval do
        include OAuth2::Provider::Rails::ControllerAuthentication
      end
    end

    initializer "oauth2_provider.initialize_middleware" do |app|
      app.middleware.use ::OAuth2::Provider::Rack::Middleware
    end
  end
end

# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require_relative "bundler_helper"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups(BundlerHelper.database))

# Load asset_sync early
require_relative 'asset_sync'

module Diaspora
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use classic autoloader for now
    config.autoloader = :classic

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths      += %W[#{config.root}/app]
    config.autoload_once_paths += %W[#{config.root}/lib]

    # Allow to decode Time from serialized columns
    config.active_record.yaml_column_permitted_classes = [Time]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Speed up precompile by not loading the environment
    config.assets.initialize_on_precompile = false

    # See lib/tasks/assets.rake: non_digest_assets
    config.assets.non_digest_assets = %w[branding/logos/asterisk.png]

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec
    end

    # Setup action mailer early
    config.action_mailer.default_url_options = {
      protocol: AppConfig.pod_uri.scheme,
      host:     AppConfig.pod_uri.authority
    }
    config.action_mailer.asset_host = AppConfig.pod_uri.to_s

    config.action_view.raise_on_missing_translations = true

    config.middleware.use Rack::OAuth2::Server::Resource::Bearer, "OpenID Connect" do |req|
      Api::OpenidConnect::OAuthAccessToken
        .valid(Time.zone.now.utc).find_by(token: req.access_token) || req.invalid_token!
    end
  end
end

Rails.application.routes.default_url_options[:host] = AppConfig.pod_uri.host
Rails.application.routes.default_url_options[:port] = AppConfig.pod_uri.port

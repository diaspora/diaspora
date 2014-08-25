require_relative 'boot'

require 'rails/all'
Bundler.require(:default, Rails.env)

# Load asset_sync early
require_relative 'asset_sync'

module Diaspora
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths      += %W{#{config.root}/app}
    config.autoload_once_paths += %W{#{config.root}/lib}

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Speed up precompile by not loading the environment
    config.assets.initialize_on_precompile = false

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w{
      aspect-contacts.js
      contact-list.js
      home.js
      ie.js
      inbox.js
      jquery.js
      jquery_ujs.js
      jquery.textchange.js
      mailchimp.js
      main.js
      mobile.js
      profile.js
      people.js
      profile.js
      publisher.js
      templates.js
      validation.js

      blueprint.css
      bootstrap.css
      bootstrap-complete.css
      bootstrap-responsive.css
      default.css
      error_pages.css
      admin.css
      mobile/mobile.css
      new-templates.css
      rtl.css
    }

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec
    end
  end
end

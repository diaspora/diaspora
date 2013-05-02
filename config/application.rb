#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'pathname'
require Pathname.new(__FILE__).expand_path.dirname.join('boot')

require 'yaml'

require 'rails/all'

# Sanitize groups to make matching :assets easier
RAILS_GROUPS = Rails.groups(:assets => %w(development test)).map { |group| group.to_sym }

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*RAILS_GROUPS)
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Diaspora
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
     config.autoload_paths      += %W{#{config.root}/app/presenters #{config.root}/app}
     config.autoload_once_paths += %W{#{config.root}/lib}

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
     config.generators do |g|
       g.template_engine :haml
       g.test_framework  :rspec
     end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.filter_parameters += [:xml]
    config.filter_parameters += [:message]
    config.filter_parameters += [:text]
    config.filter_parameters += [:bio]

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.initialize_on_precompile = false

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    # Javascripts
    config.assets.precompile += [ "aspect-contacts.js", "contact-list.js", "finder.js",
      "home.js", "ie.js", "inbox.js", "jquery.js", "jquery_ujs.js", "jquery.textchange.js",
      "login.js", "mailchimp.js", "main.js", "mobile.js", "profile.js", "people.js", "photos.js",
      "profile.js", "publisher.js", "templates.js", "validation.js" ]

    # Stylesheets
    config.assets.precompile += [ "blueprint.css", "bootstrap.css", "bootstrap-complete.css",
      "bootstrap-responsive.css", "default.css", "error_pages.css", "login.css", "mobile.css",
      "new-templates.css", "rtl.css" ]

    # Rails Admin - these assets need to be added here since the Engine initializer
    # doesn't run with initialize_on_precompile disabled. This list is taken
    # directly from the Rails Admin Engine initializer.
    config.assets.precompile += ['rails_admin/rails_admin.js', 'rails_admin/rails_admin.css',
      'rails_admin/jquery.colorpicker.js', 'rails_admin/jquery.colorpicker.css']

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

  end
end

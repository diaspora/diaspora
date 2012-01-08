#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.expand_path('../boot', __FILE__)

# Needed for versions of ruby 1.9.2 that were compiled with libyaml.
# They use psych by default which doesn't handle having a default set of parameters.
# See bug #1120.
require 'yaml'
if RUBY_VERSION.include? '1.9'
  YAML::ENGINE.yamler= 'syck'
end

require 'rails/all'
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)


module Diaspora
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
     #config.autoload_paths += %W(#{config.root}/lib)
     config.autoload_paths += %W(#{config.root}/lib)
     config.autoload_paths += %W(#{config.root}/lib/*)
     config.autoload_paths += %W(#{config.root}/lib/*/*)
     config.autoload_paths += %W(#{config.root}/lib/*/*/*)

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

  end
end

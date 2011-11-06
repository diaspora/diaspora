#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# check what database you have
def postgres?
  @using_postgres ||= defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
end

def sqlite?
  @using_sqlite ||= defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter) && ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter
end

# Load the rails application
require File.expand_path('../application', __FILE__)
Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

if File.exists?(File.expand_path("./config/locale_settings.yml"))
  locale_settings = YAML::load(File.open(File.expand_path("./config/locale_settings.yml")))
  AVAILABLE_LANGUAGES = (locale_settings['available'].length > 0) ? locale_settings['available'] : { :en => 'English' }
  DEFAULT_LANGUAGE = (AVAILABLE_LANGUAGES.include?(locale_settings['default'])) ? locale_settings['default'] : AVAILABLE_LANGUAGES.keys[0].to_s
  AVAILABLE_LANGUAGE_CODES = locale_settings['available'].keys.map { |v| v.to_s }
  LANGUAGE_CODES_MAP = locale_settings['fallbacks']
  RTL_LANGUAGES = locale_settings['rtl']
else
  AVAILABLE_LANGUAGES = { :en => 'English' }
  DEFAULT_LANGUAGE = 'en'
  AVAILABLE_LANGUAGE_CODES = ['en']
  LANGUAGE_CODES_MAP = {}
  RTL_LANGUAGES = []
end

# Blacklist of usernames
USERNAME_BLACKLIST = ['admin', 'administrator', 'hostmaster', 'info', 'postmaster', 'root', 'ssladmin', 
  'ssladministrator', 'sslwebmaster', 'sysadmin', 'webmaster', 'support', 'contact', 'example_user1dsioaioedfhgoiesajdigtoearogjaidofgjo']

# Initialize the rails application
Diaspora::Application.initialize!

# allow token auth only for posting activitystream photos
module Devise
  module Strategies
    class TokenAuthenticatable < Authenticatable
      private
      def valid_request?
        params[:controller] == "activity_streams/photos" && params[:action] == "create"
      end
    end
  end
end

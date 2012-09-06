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
require File.join(Rails.root, "lib", "exceptions")

Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = true

# Blacklist of usernames
USERNAME_BLACKLIST = ['admin', 'administrator', 'hostmaster', 'info', 'postmaster', 'root', 'ssladmin', 
  'ssladministrator', 'sslwebmaster', 'sysadmin', 'webmaster', 'support', 'contact', 'example_user1dsioaioedfhgoiesajdigtoearogjaidofgjo']

# Initialize the rails application
Diaspora::Application.initialize!
require Rails.root.join('lib', 'federation_logger')

# allow token auth only for posting activitystream photos
module Devise
  module Strategies
    class TokenAuthenticatable < Authenticatable
      private
      def valid_params_request?
        params[:controller] == "activity_streams/photos" && params[:action] == "create"
      end
    end
  end
end

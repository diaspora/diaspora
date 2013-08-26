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

require 'pathname'
# Load the rails application
require_relative 'application'

# Initialize the rails application
Diaspora::Application.initialize!

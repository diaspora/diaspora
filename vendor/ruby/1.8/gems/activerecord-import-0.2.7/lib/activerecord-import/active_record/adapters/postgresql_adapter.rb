require "active_record/connection_adapters/postgresql_adapter"
require "activerecord-import/adapters/postgresql_adapter"

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  include ActiveRecord::Import::PostgreSQLAdapter::InstanceMethods
end


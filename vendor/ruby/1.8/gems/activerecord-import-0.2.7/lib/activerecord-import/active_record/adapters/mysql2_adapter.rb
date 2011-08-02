require "active_record/connection_adapters/mysql2_adapter"
require "activerecord-import/adapters/mysql_adapter"

class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  include ActiveRecord::Import::MysqlAdapter::InstanceMethods
end
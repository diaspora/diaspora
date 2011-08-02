ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

module Connections
  def self.extended(host)

    host.connection.execute <<-eosql
      CREATE TABLE #{host.table_name} (
        #{host.primary_key} integer PRIMARY KEY AUTOINCREMENT
      )
    eosql
  end
end

class NonActiveRecordModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class MockableModel < ActiveRecord::Base
  extend Connections
  has_one :associated_model
end

class SubMockableModel < MockableModel
end

class AssociatedModel < ActiveRecord::Base
  extend Connections
  belongs_to :mockable_model
end

class AlternatePrimaryKeyModel < ActiveRecord::Base
  self.primary_key = :my_id
  extend Connections
  attr_accessor :my_id
end

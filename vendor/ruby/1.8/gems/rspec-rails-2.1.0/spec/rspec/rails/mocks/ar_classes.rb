module NoConnections
  def self.included(mod)
    (class << mod; self; end).class_eval do
      def columns
        []
      end

      def connection
        RSpec::Mocks::Mock.new.as_null_object
      end
    end
  end
end

class NonActiveRecordModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class MockableModel < ActiveRecord::Base
  include NoConnections
  has_one :associated_model
end

class SubMockableModel < MockableModel
end

class AssociatedModel < ActiveRecord::Base
  include NoConnections
  belongs_to :mockable_model
end

class AlternatePrimaryKeyModel < ActiveRecord::Base
  include NoConnections
  self.primary_key = :my_id
  attr_accessor :my_id
end

class ConnectableModel < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3',
                       :database => ':memory:'

  connection.execute <<-eosql
    CREATE TABLE connectable_models (
      id integer PRIMARY KEY AUTOINCREMENT
    )
  eosql
end

require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "test.db"
)

require "schema.rb"

class ExampleResourceOwner < ActiveRecord::Base
  def self.authenticate_with_username_and_password(*args)
    find_by_username_and_password(*args)
  end
end

OAuth2::Provider.configure do |config|
  config.resource_owner_class_name = 'ExampleResourceOwner'
end
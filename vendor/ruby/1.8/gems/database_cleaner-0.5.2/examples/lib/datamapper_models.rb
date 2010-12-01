require "dm-core"

# only to please activerecord API used in database_cleaner/examples/features/step_definitions
# yes, i know that's lazy ...
require "dm-validations"
require "dm-aggregates"

DataMapper.setup(:default, "sqlite3::memory:")

class Widget
  include DataMapper::Resource
  property :id,   Serial
  property :name, String
end

Widget.auto_migrate!
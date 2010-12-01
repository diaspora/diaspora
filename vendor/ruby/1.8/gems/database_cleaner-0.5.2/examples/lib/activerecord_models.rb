require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "#{"jdbc" if defined?(JRUBY_VERSION)}sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :widgets do |t|
    t.string :name
  end
end

class Widget < ActiveRecord::Base
end

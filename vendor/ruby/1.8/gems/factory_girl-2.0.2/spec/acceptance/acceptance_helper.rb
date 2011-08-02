require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
)

RSpec.configure do |config|
  config.include DefinesConstants
end


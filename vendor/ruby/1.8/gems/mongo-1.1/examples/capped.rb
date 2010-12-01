$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')
db.drop_collection('test')

# A capped collection has a max size and, optionally, a max number of records.
# Old records get pushed out by new ones once the size or max num records is reached.
coll = db.create_collection('test', :capped => true, :size => 1024, :max => 12)

100.times { |i| coll.insert('a' => i+1) }

# We will only see the last 12 records
coll.find().each { |row| p row }

coll.drop

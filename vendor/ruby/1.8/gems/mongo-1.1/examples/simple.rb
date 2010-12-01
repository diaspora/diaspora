$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')
coll = db.collection('test')

# Erase all records from collection, if any
coll.remove

# Insert 3 records
3.times { |i| coll.insert({'a' => i+1}) }

puts "There are #{coll.count()} records in the test collection. Here they are:"
coll.find().each { |doc| puts doc.inspect }

# Destroy the collection
coll.drop

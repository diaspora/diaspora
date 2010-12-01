$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo'
require 'pp'

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

# Cursors don't run their queries until you actually attempt to retrieve data
# from them.

# Find returns a Cursor, which is Enumerable. You can iterate:
coll.find().each { |row| pp row }

# You can turn it into an array:
array = coll.find().to_a

# You can iterate after turning it into an array (the cursor will iterate over
# the copy of the array that it saves internally.)
cursor = coll.find()
array = cursor.to_a
cursor.each { |row| pp row }

# You can get the next object
first_object = coll.find().next_document

# next_document returns nil if there are no more objects that match
cursor = coll.find()
obj = cursor.next_document
while obj
  pp obj
  obj = cursor.next_document
end

# Destroy the collection
coll.drop

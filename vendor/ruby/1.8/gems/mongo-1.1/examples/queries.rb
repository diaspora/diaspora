$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo'
require 'pp'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')
coll = db.collection('test')

# Remove all records, if any
coll.remove

# Insert three records
coll.insert('a' => 1)
coll.insert('a' => 2)
coll.insert('b' => 3)

# Count.
puts "There are #{coll.count()} records."

# Find all records. find() returns a Cursor.
cursor = coll.find()

# Print them. Note that all records have an _id automatically added by the
# database. See pk.rb for an example of how to use a primary key factory to
# generate your own values for _id.
cursor.each { |row| pp row }

# Cursor has a to_a method that slurps all records into memory.
rows = coll.find().to_a
rows.each { |row| pp row }

# See Collection#find. From now on in this file, we won't be printing the
# records we find.
coll.find('a' => 1)

# Find records sort by 'a', skip 1, limit 2 records.
# Sort can be single name, array, or hash.
coll.find({}, {:skip => 1, :limit => 2, :sort => 'a'})

# Find all records with 'a' > 1. There is also $lt, $gte, and $lte.
coll.find({'a' => {'$gt' => 1}})
coll.find({'a' => {'$gt' => 1, '$lte' => 3}})

# Find all records with 'a' in a set of values.
coll.find('a' => {'$in' => [1,2]})

# Find by regexp
coll.find('a' => /[1|2]/)

# Print query explanation
pp coll.find('a' => /[1|2]/).explain()

# Use a hint with a query. Need an index. Hints can be stored with the
# collection, in which case they will be used with all queries, or they can be
# specified per query, in which case that hint overrides the hint associated
# with the collection if any.
coll.create_index('a')
coll.hint = 'a'

# You will see a different explanation now that the hint is in place
pp coll.find('a' => /[1|2]/).explain()

# Override hint for single query
coll.find({'a' => 1}, :hint => 'b')

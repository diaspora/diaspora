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

# Insert record with all sorts of values
coll.insert('array' => [1, 2, 3],
            'string' => 'hello',
            'hash' => {'a' => 1, 'b' => 2},
            'date' => Time.now, # milliseconds only; microseconds are not stored
            'oid' => ObjectID.new,
            'binary' => Binary.new([1, 2, 3]),
            'int' => 42,
            'float' => 33.33333,
            'regex' => /foobar/i,
            'boolean' => true,
            'where' => Code.new('this.x == 3'),
            'dbref' => DBRef.new(coll.name, ObjectID.new),
            'null' => nil,
            'symbol' => :zildjian)

pp coll.find().next_document

coll.remove

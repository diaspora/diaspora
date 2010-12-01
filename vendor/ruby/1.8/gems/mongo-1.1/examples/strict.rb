$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')

db.drop_collection('does-not-exist')
db.create_collection('test')

db.strict = true

begin
  # Can't reference collection that does not exist
  db.collection('does-not-exist')
  puts "error: expected exception"
rescue => ex
  puts "expected exception: #{ex}"
end

begin
  # Can't create collection that already exists
  db.create_collection('test')
  puts "error: expected exception"
rescue => ex
  puts "expected exception: #{ex}"
end

db.strict = false
db.drop_collection('test')

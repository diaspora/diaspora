$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
def assert
  raise "Failed!" unless yield
end

require 'mongo'
include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-examples')

data = "hello, world!"

grid = Grid.new(db)

# Write a new file. data can be a string or an io object responding to #read.
id = grid.put(data, :filename => 'hello.txt')

# Read it and print out the contents
file = grid.get(id)
puts file.read

# Delete the file
grid.delete(id)

begin
grid.get(id)
rescue => e
  assert {e.class == Mongo::GridError}
end

# Metadata
id = grid.put(data, :filename => 'hello.txt', :content_type => 'text/plain', :metadata => {'name' => 'hello'})
file = grid.get(id)

p file.content_type
p file.metadata.inspect
p file.chunk_size
p file.file_length
p file.filename
p file.data

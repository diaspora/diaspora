$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || Connection::DEFAULT_PORT

puts ">> Connecting to #{host}:#{port}"
db = Connection.new(host, port).db('ruby-mongo-index_test')

class Exception
  def errmsg
    "%s: %s\n%s" % [self.class, message, (backtrace || []).join("\n") << "\n"]
  end
end

puts ">> Dropping collection test"
begin
  res = db.drop_collection('test')
  puts "dropped : #{res.inspect}"
rescue => e
  puts "Error: #{e.errmsg}"
end

puts ">> Creating collection test"
begin
  coll = db.collection('test')
  puts "created : #{coll.inspect}"
rescue => e
  puts "Error: #{e.errmsg}"
end

OBJS_COUNT = 100

puts ">> Generating test data"
msgs = %w{hola hello aloha ciao}
arr = (0...OBJS_COUNT).collect {|x| { :number => x, :rndm => (rand(5)+1), :msg => msgs[rand(4)] }}
puts "generated"

puts ">> Inserting data (#{arr.size})"
coll.insert(arr)
puts "inserted"

puts ">> Creating index"
#res = coll.create_index "all", :_id => 1, :number => 1, :rndm => 1, :msg => 1
res = coll.create_index [[:number, 1], [:rndm, 1], [:msg, 1]]
puts "created index: #{res.inspect}"
# ============================ Mongo Log ============================
# Fri Dec  5 14:45:02 Adding all existing records for ruby-mongo-console.test to new index
# ***
# Bad data or size in BSONElement::size()
# bad type:30
# totalsize:11 fieldnamesize:4
# lastrec:
# Fri Dec  5 14:45:02 ruby-mongo-console.system.indexes Assertion failure false jsobj.cpp a0
# Fri Dec  5 14:45:02  database: ruby-mongo-console op:7d2 0
# Fri Dec  5 14:45:02  ns: ruby-mongo-console.system.indexes

puts ">> Gathering index information"
begin
  res = coll.index_information
  puts "index_information : #{res.inspect}"
rescue => e
  puts "Error: #{e.errmsg}"
end
# ============================ Console Output ============================
# RuntimeError: Keys for index on return from db was nil. Coll = ruby-mongo-console.test
#         from ./bin/../lib/mongo/db.rb:135:in `index_information'
#         from (irb):11:in `collect'
#         from ./bin/../lib/mongo/cursor.rb:47:in `each'
#         from ./bin/../lib/mongo/db.rb:130:in `collect'
#         from ./bin/../lib/mongo/db.rb:130:in `index_information'
#         from ./bin/../lib/mongo/collection.rb:74:in `index_information'
#         from (irb):11

puts ">> Dropping index"
begin
  res = coll.drop_index "number_1_rndm_1_msg_1"
  puts "dropped : #{res.inspect}"
rescue => e
  puts "Error: #{e.errmsg}"
end

# ============================ Console Output ============================
# => {"nIndexesWas"=>2.0, "ok"=>1.0}
# ============================ Mongo Log ============================
# 0x41802a 0x411549 0x42bac6 0x42c1f6 0x42c55b 0x42e6f7 0x41631e 0x41a89d 0x41ade2 0x41b448 0x4650d2 0x4695ad
#  db/db(_Z12sayDbContextPKc+0x17a) [0x41802a]
#  db/db(_Z8assertedPKcS0_j+0x9) [0x411549]
#  db/db(_ZNK11BSONElement4sizeEv+0x1f6) [0x42bac6]
#  db/db(_ZN7BSONObj8getFieldEPKc+0xa6) [0x42c1f6]
#  db/db(_ZN7BSONObj14getFieldDottedEPKc+0x11b) [0x42c55b]
#  db/db(_ZN7BSONObj19extractFieldsDottedES_R14BSONObjBuilder+0x87) [0x42e6f7]
#  db/db(_ZN12IndexDetails17getKeysFromObjectER7BSONObjRSt3setIS0_St4lessIS0_ESaIS0_EE+0x24e) [0x41631e]
#  db/db(_Z12_indexRecordR12IndexDetailsR7BSONObj7DiskLoc+0x5d) [0x41a89d]
#  db/db(_Z18addExistingToIndexPKcR12IndexDetails+0xb2) [0x41ade2]
#  db/db(_ZN11DataFileMgr6insertEPKcPKvib+0x508) [0x41b448]
#  db/db(_Z14receivedInsertR7MessageRSt18basic_stringstreamIcSt11char_traitsIcESaIcEE+0x112) [0x4650d2]
#  db/db(_Z10connThreadv+0xb4d) [0x4695ad]
# Fri Dec  5 14:45:02 ruby-mongo-console.system.indexes  Caught Assertion insert, continuing
# Fri Dec  5 14:47:59 CMD: deleteIndexes ruby-mongo-console.test
#   d->nIndexes was 2
#   alpha implementation, space not reclaimed

puts ">> Gathering index information"
begin
  res = coll.index_information
  puts "index_information : #{res.inspect}"
rescue => e
  puts "Error: #{e.errmsg}"
end
# ============================ Console Output ============================
# RuntimeError: Keys for index on return from db was nil. Coll = ruby-mongo-console.test
#         from ./bin/../lib/mongo/db.rb:135:in `index_information'
#         from (irb):15:in `collect'
#         from ./bin/../lib/mongo/cursor.rb:47:in `each'
#         from ./bin/../lib/mongo/db.rb:130:in `collect'
#         from ./bin/../lib/mongo/db.rb:130:in `index_information'
#         from ./bin/../lib/mongo/collection.rb:74:in `index_information'
#         from (irb):15

puts ">> Closing connection"
db.close
puts "closed"

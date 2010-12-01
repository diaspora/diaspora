require 'rubygems'
require 'mongo'

TRIALS = 100000

t0 = Time.now

TRIALS.times do
  BSON::BSON_CODER.serialize(:_id => BSON::ObjectId.new)
end
t1 = Time.now

puts "Took #{t1 - t0} seconds"

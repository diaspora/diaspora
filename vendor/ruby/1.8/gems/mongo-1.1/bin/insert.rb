#!/usr/bin/env ruby

require 'rubygems'
require 'mongo'
require 'date'
require 'logger'
include Mongo

@logger = Logger.new(File.open("m.log", "w"))
require 'ruby-prof'

num_inserts = 100000
if( ARGV.size() > 0 ) then
num_inserts = ARGV[0].to_i()
end
db   = Connection.new('localhost', 27017).db('sample-db')
coll = db.collection('test')
coll.remove()
sleep(2)

puts "Testing #{num_inserts} inserts"
start = Time.now()

#RubyProf.start
num_inserts.times do |i|
  coll.insert({'a' => i+1})
end
#result = RubyProf.stop
ending = Time.now
total = ending - start

puts "Took #{total} seconds, meaning #{num_inserts / total} per second."

#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT, 0)

# encoding: utf-8

$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'eventmachine'
require 'mysql2/em'

EM.run do
  client1 = Mysql2::EM::Client.new
  defer1 = client1.query "SELECT sleep(3) as first_query"
  defer1.callback do |result|
    puts "Result: #{result.to_a.inspect}"
  end

  client2 = Mysql2::EM::Client.new
  defer2 = client2.query "SELECT sleep(1) second_query"
  defer2.callback do |result|
    puts "Result: #{result.to_a.inspect}"
  end
end
# encoding: utf-8

$LOAD_PATH.unshift 'lib'
require 'mysql2'
require 'timeout'

threads = []
# Should never exceed worst case 3.5 secs across all 20 threads
Timeout.timeout(3.5) do
  20.times do
    threads << Thread.new do
      overhead = rand(3)
      puts ">> thread #{Thread.current.object_id} query, #{overhead} sec overhead"
      # 3 second overhead per query
      Mysql2::Client.new(:host => "localhost", :username => "root").query("SELECT sleep(#{overhead}) as result")
      puts "<< thread #{Thread.current.object_id} result, #{overhead} sec overhead"
    end
  end
  threads.each{|t| t.join }
end
# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'benchmark'
require 'mysql'
require 'mysql2'
require 'do_mysql'

number_of = 100
database = 'test'
sql = "SELECT * FROM mysql2_test LIMIT 100"

Benchmark.bmbm do |x|
  mysql2 = Mysql2::Client.new(:host => "localhost", :username => "root")
  mysql2.query "USE #{database}"
  x.report do
    puts "Mysql2"
    number_of.times do
      mysql2_result = mysql2.query sql, :symbolize_keys => true
      mysql2_result.each do |res|
        # puts res.inspect
      end
    end
  end

  mysql = Mysql.new("localhost", "root")
  mysql.query "USE #{database}"
  x.report do
    puts "Mysql"
    number_of.times do
      mysql_result = mysql.query sql
      mysql_result.each_hash do |res|
        # puts res.inspect
      end
    end
  end

  do_mysql = DataObjects::Connection.new("mysql://localhost/#{database}")
  command = DataObjects::Mysql::Command.new do_mysql, sql
  x.report do
    puts "do_mysql"
    number_of.times do
      do_result = command.execute_reader
      do_result.each do |res|
        # puts res.inspect
      end
    end
  end
end
# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'benchmark'
require 'mysql'
require 'mysql2'
require 'do_mysql'

def run_escape_benchmarks(str, number_of = 1000)
  Benchmark.bmbm do |x|
    mysql = Mysql.new("localhost", "root")
    x.report do
      puts "Mysql #{str.inspect}"
      number_of.times do
        mysql.quote str
      end
    end

    mysql2 = Mysql2::Client.new(:host => "localhost", :username => "root")
    x.report do
      puts "Mysql2 #{str.inspect}"
      number_of.times do
        mysql2.escape str
      end
    end

    do_mysql = DataObjects::Connection.new("mysql://localhost/test")
    x.report do
      puts "do_mysql #{str.inspect}"
      number_of.times do
        do_mysql.quote_string str
      end
    end
  end
end

run_escape_benchmarks "abc'def\"ghi\0jkl%mno"
run_escape_benchmarks "clean string"
# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

raise Mysql2::Mysql2Error.new("GC allocation benchmarks only supported on Ruby 1.9!") unless RUBY_VERSION =~ /1\.9/

require 'rubygems'
require 'benchmark'
require 'active_record'

ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true

class Mysql2Model < ActiveRecord::Base
  set_table_name :mysql2_test
end

def bench_allocations(feature, iterations = 10, &blk)
  puts "GC overhead for #{feature}"
  Mysql2Model.establish_connection(:adapter => 'mysql2', :database => 'test')
  GC::Profiler.clear
  GC::Profiler.enable
  iterations.times{ blk.call }
  GC::Profiler.report(STDOUT)
  GC::Profiler.disable
end

bench_allocations('coercion') do
  Mysql2Model.all(:limit => 1000).each{ |r|
    r.attributes.keys.each{ |k|
      r.send(k.to_sym)
    }
  }
end
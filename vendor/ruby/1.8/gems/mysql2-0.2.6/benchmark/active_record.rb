# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'benchmark'
require 'active_record'

ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true

number_of = 10
mysql2_opts = {
  :adapter => 'mysql2',
  :database => 'test'
}
mysql_opts = {
  :adapter => 'mysql',
  :database => 'test'
}

class Mysql2Model < ActiveRecord::Base
  set_table_name :mysql2_test
end

class MysqlModel < ActiveRecord::Base
  set_table_name :mysql2_test
end

Benchmark.bmbm do |x|
  x.report do
    Mysql2Model.establish_connection(mysql2_opts)
    puts "Mysql2"
    number_of.times do
      Mysql2Model.all(:limit => 1000).each{ |r|
        r.attributes.keys.each{ |k|
          r.send(k.to_sym)
        }
      }
    end
  end

  x.report do
    MysqlModel.establish_connection(mysql_opts)
    puts "Mysql"
    number_of.times do
      MysqlModel.all(:limit => 1000).each{ |r|
        r.attributes.keys.each{ |k|
          r.send(k.to_sym)
        }
      }
    end
  end
end
require 'rubygems'
require 'rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

['dm-core', 'mongoid', 'active_record', 'mongo_mapper'].each do |orm|
  begin
    require orm
  rescue LoadError
    puts "#{orm} not available"
  end
end

require 'dm-active_model' if defined?(DataMapper)
require 'orm_adapter'
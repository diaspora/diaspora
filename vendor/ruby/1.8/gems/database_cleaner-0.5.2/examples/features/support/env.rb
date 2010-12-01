require 'rubygems'
require 'spec/expectations'

orm      = ENV['ORM']
strategy = ENV['STRATEGY']

if orm && strategy

  begin
    require "#{File.dirname(__FILE__)}/../../lib/#{orm}_models"
  rescue LoadError
    raise "You don't have the #{orm} ORM installed"
  end

  $:.unshift(File.dirname(__FILE__) + '/../../../lib')
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = strategy.to_sym
  
else
  raise "Run 'ORM=activerecord|datamapper|mongomapper|couchpotato STRATEGY=transaction|truncation cucumber examples/features'"
end

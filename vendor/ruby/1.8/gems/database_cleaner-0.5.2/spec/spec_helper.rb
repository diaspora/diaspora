require 'rubygems'
require 'spec'
require 'active_record'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'database_cleaner'

Spec::Runner.configure do |config|
  
end

alias running lambda

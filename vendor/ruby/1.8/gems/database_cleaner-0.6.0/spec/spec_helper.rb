require "rubygems"

require "bundler"
Bundler.setup


require 'spec'
#require 'active_record'
#require 'mongo_mapper'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'database_cleaner'



Spec::Runner.configure do |config|

end

alias running lambda

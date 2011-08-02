require 'pathname'
test_dir = Pathname.new File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "fileutils"
require "rubygems"

ENV["RAILS_ENV"] = "test"

require "bundler"
Bundler.setup

require "logger"
require 'test/unit'
require "active_record"
require "active_record/fixtures"
require "active_support/test_case"

require "delorean"
require "ruby-debug"

adapter = ENV["ARE_DB"] || "sqlite3"

FileUtils.mkdir_p 'log'
ActiveRecord::Base.logger = Logger.new("log/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG
ActiveRecord::Base.configurations["test"] = YAML.load(test_dir.join("database.yml").open)[adapter]

require "activerecord-import"
ActiveRecord::Base.establish_connection "test"

ActiveSupport::Notifications.subscribe(/active_record.sql/) do |event, _, _, _, hsh|
  ActiveRecord::Base.logger.info hsh[:sql]
end

require "factory_girl"
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each{ |file| require file }

# Load base/generic schema
require test_dir.join("schema/version")
require test_dir.join("schema/generic_schema")
adapter_schema = test_dir.join("schema/#{adapter}_schema.rb")
require adapter_schema if File.exists?(adapter_schema)

Dir[File.dirname(__FILE__) + "/models/*.rb"].each{ |file| require file }

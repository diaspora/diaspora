ENV["RAILS_ENV"] ||= "culerity"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

Cucumber::Rails::World.use_transactional_fixtures = false
ActionController::Base.allow_rescue = false

require 'cucumber/formatter/unicode'
require 'cucumber/rails/rspec'
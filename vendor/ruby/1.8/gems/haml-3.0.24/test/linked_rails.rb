# allows testing with edge Rails by creating a test/rails symlink
linked_rails = File.dirname(__FILE__) + '/rails'

if File.exists?(linked_rails) && !$:.include?(linked_rails + '/activesupport/lib')
  puts "[ using linked Rails ]"
  $:.unshift linked_rails + '/activesupport/lib'
  $:.unshift linked_rails + '/actionpack/lib'
  $:.unshift linked_rails + '/railties/lib'
end
require 'rubygems'
require 'action_controller'
require 'action_view'

begin
  # Necessary for Rails 3
  require 'rails'
rescue LoadError
  # Necessary for Rails 2.3.7
  require 'initializer'
rescue LoadError
end

if defined?(Rails::Application) # Rails 3
  class TestApp < Rails::Application
    config.root = File.join(File.dirname(__FILE__), "../..")
  end
  Rails.application = TestApp
elsif defined?(RAILS_ROOT)
  RAILS_ROOT.replace(File.join(File.dirname(__FILE__), "../.."))
else
  RAILS_ROOT = File.join(File.dirname(__FILE__), "../..")
end

ActionController::Base.logger = Logger.new(nil)

# Load plugins from test/plugins.
# This will only work with very basic plugins,
# since we don't want to load the entirety of Rails.
Dir[File.dirname(__FILE__) + '/plugins/*'].each do |plugin|
  $: << plugin + '/lib'
  eval(File.read(plugin + '/init.rb'))
end

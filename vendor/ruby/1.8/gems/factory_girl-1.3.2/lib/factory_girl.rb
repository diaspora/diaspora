require 'factory_girl/proxy'
require 'factory_girl/proxy/build'
require 'factory_girl/proxy/create'
require 'factory_girl/proxy/attributes_for'
require 'factory_girl/proxy/stub'
require 'factory_girl/factory'
require 'factory_girl/attribute'
require 'factory_girl/attribute/static'
require 'factory_girl/attribute/dynamic'
require 'factory_girl/attribute/association'
require 'factory_girl/attribute/callback'
require 'factory_girl/sequence'
require 'factory_girl/aliases'

# Shortcut for Factory.default_strategy.
#
# Example:
#   Factory(:user, :name => 'Joe')
def Factory (name, attrs = {})
  Factory.default_strategy(name, attrs)
end

class Factory
  VERSION = "1.3.2"
end

if defined?(Rails) && Rails::VERSION::MAJOR == 2
  require 'factory_girl/rails2'
end


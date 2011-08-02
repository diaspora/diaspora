require 'factory_girl/proxy'
require 'factory_girl/proxy/build'
require 'factory_girl/proxy/create'
require 'factory_girl/proxy/attributes_for'
require 'factory_girl/proxy/stub'
require 'factory_girl/registry'
require 'factory_girl/factory'
require 'factory_girl/attribute'
require 'factory_girl/attribute/static'
require 'factory_girl/attribute/dynamic'
require 'factory_girl/attribute/association'
require 'factory_girl/attribute/callback'
require 'factory_girl/attribute/sequence'
require 'factory_girl/attribute/implicit'
require 'factory_girl/sequence'
require 'factory_girl/aliases'
require 'factory_girl/definition_proxy'
require 'factory_girl/syntax/methods'
require 'factory_girl/syntax/default'
require 'factory_girl/syntax/vintage'
require 'factory_girl/find_definitions'
require 'factory_girl/deprecated'
require 'factory_girl/version'

if defined?(Rails) && Rails::VERSION::MAJOR == 2
  require 'factory_girl/rails2'
end

module FactoryGirl
  def self.factories
    @factories ||= Registry.new
  end

  def self.register_factory(factory)
    factories.add(factory)
  end

  def self.factory_by_name(name)
    factories.find(name)
  end

  def self.sequences
    @sequences ||= Registry.new
  end

  def self.register_sequence(sequence)
    sequences.add(sequence)
  end

  def self.sequence_by_name(name)
    sequences.find(name)
  end
end

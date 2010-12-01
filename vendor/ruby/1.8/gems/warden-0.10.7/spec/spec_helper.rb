# encoding: utf-8
$TESTING=true

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))
require 'warden'

require 'rubygems'
require 'rack'

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

Spec::Runner.configure do |config|
  config.include(Warden::Spec::Helpers)

  def load_strategies
    Dir[File.join(File.dirname(__FILE__), "helpers", "strategies", "**/*.rb")].each do |f|
      load f
    end
  end
end

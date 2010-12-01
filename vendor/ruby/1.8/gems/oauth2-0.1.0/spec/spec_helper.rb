$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'oauth2'
require 'rspec'
require 'rspec/autorun'

Faraday.default_adapter = :test

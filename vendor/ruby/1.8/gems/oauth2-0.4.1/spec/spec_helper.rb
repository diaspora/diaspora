require "rubygems"
require "bundler"
Bundler.setup

require 'simplecov'
SimpleCov.start
require 'oauth2'
require 'rspec'
require 'rspec/autorun'

Faraday.default_adapter = :test

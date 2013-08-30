# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Ensure Builder is loaded
require 'active_support/builder' unless defined?(Builder)

# Load configuration early
require_relative 'load_config'

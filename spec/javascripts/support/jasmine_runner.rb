# frozen_string_literal: true

$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

ENV["JASMINE_BROWSER"] = "firefox"

require 'rubygems'
require 'json'
require 'jasmine'
require 'rspec'

jasmine_config = Jasmine::Config.new
spec_builder = Jasmine::SpecBuilder.new(jasmine_config)

should_stop = false

RSpec.configuration.after(:suite) do
    spec_builder.stop if should_stop
end

spec_builder.start
should_stop = true
spec_builder.declare_suites

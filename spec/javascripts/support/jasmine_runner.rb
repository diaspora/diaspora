$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

ENV["JASMINE_BROWSER"] = "firefox"

require 'rubygems'
require 'json'
require 'jasmine'
require 'rspec'
jasmine_config_overrides = File.expand_path(File.join(File.dirname(__FILE__), 'jasmine_config.rb'))

begin 
  require jasmine_config_overrides if File.exists?(jasmine_config_overrides)
rescue Exception => e
  #we do this because when we are locally developing JS, our local jammit
  # helps us re-run jasmine tests by jammiting every time.
  #on ci, this causes problems, but we only need to jammit once
end

jasmine_config = Jasmine::Config.new
spec_builder = Jasmine::SpecBuilder.new(jasmine_config)

should_stop = false

RSpec.configuration.after(:suite) do
    spec_builder.stop if should_stop
end

spec_builder.start
should_stop = true
spec_builder.declare_suites

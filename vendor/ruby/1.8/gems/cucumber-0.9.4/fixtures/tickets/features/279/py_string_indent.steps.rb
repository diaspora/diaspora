begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

require File.dirname(__FILE__) + '/../../../../features/step_definitions/cucumber_steps.rb'
require File.dirname(__FILE__) + '/../../../../features/support/env.rb'

Given /^multiline string$/ do |string|
  @string = string
end

Then /^string is$/ do |string|
  @string.should == string
end

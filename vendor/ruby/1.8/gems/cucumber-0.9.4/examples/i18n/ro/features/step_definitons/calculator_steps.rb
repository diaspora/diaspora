# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Given /introduc (\d+)/ do |n|
  @calc.push n.to_i
end

When 'apas suma' do
  @result = @calc.add
end

Then /rezultatul trebuie sa fie (\d*)/ do |result|
  @result.should == result.to_i
end

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

Given /שהזנתי (\d+) למחשבון/ do |n|
  @calc.push n.to_i
end

When /אני לוחץ על (.+)/ do |op|
  @result = @calc.send op
end

Then /התוצאה על המסך צריכה להיות (.*)/ do |result|
  @result.should == result.to_f
end

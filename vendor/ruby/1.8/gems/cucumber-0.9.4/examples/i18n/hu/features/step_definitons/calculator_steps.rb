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

Ha /^beütök a számológépbe egy (\d+)\-(?:es|as|ös|ás)t$/ do |n|
  @calc.push n.to_i
end

Majd /^megnyomom az? (\w+) gombot$/ do |op|
  @result = @calc.send op
end

Akkor /^eredményül (.*)\-(?:e|a|ö|á|)t kell kapnom$/ do |result|
  @result.should == result.to_f
end


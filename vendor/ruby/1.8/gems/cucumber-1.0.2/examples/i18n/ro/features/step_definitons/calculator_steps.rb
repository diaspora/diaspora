# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 
require 'calculator'

Datfiind /un calculator/ do
  @calc = Calculator.new
end

Cand /introduc (\d+)/ do |n|
  @calc.push n.to_i
end

Cand 'apăs tasta Egal' do
  @result = @calc.add
end

Atunci /ecranul trebuie să afişeze (\d*)/ do |result|
  @result.should == result.to_i
end

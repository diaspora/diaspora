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

Zadato /Unesen (\d+) broj u kalkulator/ do |n|
  @calc.push n.to_i
end

Kada /pritisnem (\w+)/ do |op|
  @result = @calc.send op
end

Onda /bi trebalo da bude (.*) prikazano na ekranu/ do |result|
  @result.should == result.to_f
end

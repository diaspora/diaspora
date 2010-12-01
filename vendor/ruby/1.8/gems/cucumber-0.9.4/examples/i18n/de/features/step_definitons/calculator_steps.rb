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

Angenommen /ich habe (\d+) in den Taschenrechner eingegeben/ do |n|
  @calc.push n.to_i
end

Wenn /ich (\w+) drücke/ do |op|
  @result = @calc.send op
end

Dann /sollte das Ergebniss auf dem Bildschirm (.*) sein/ do |result|
  @result.should == result.to_f
end

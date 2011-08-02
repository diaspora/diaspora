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

Zakładając /wprowadzenie do kalkulatora liczby (\d+)/ do |n|
  @calc.push n.to_i
end

Jeżeli /nacisnę (\w+)/ do |op|
  @result = @calc.send op
end

Wtedy /rezultat (.*) wyświetli się na ekranie/ do |result|
  @result.should == result.to_f
end

# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end 
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculador'

Before do
  @calc = Calculador.new
end

Dado /que he introducido (\d+) en la calculadora/ do |n|
  @calc.push n.to_i
end

Cuando /oprimo el (\w+)/ do |op|
  @result = @calc.send op
end

Entonces /el resultado debe ser (.*) en la pantalla/ do |result|
  @result.should == result.to_f
end
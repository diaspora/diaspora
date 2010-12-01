# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 
require 'calculadora'

Before do
  @calc = Calculadora.new
end

Donat /que he introduït (\d+) a la calculadora/ do |n|
  @calc.push n.to_i
end

Quan /premo el (\w+)/ do |op|
  @result = @calc.send op
end

Aleshores /el resultat ha de ser (\d+) a la pantalla/ do |result|
  @result.should == result.to_f
end

# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib') 
require 'hesap_makinesi'

Before do
  @calc = HesapMakinesi.new
end

After do
end

Given /hesap makinesine (\d+) girdim/ do |n|
  @calc.push n.to_i
end

When /(\w+) tuşuna basarsam/ do |op|
  @result = @calc.send op
end

Then /ekrandaki sonuç (.*) olmalı/ do |result|
  @result.should == result.to_f
end

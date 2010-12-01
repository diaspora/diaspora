# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end
require 'cucumber/formatter/unicode'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'laskin'

Before do
  @laskin = Laskin.new
end

After do
end

Given /että olen syöttänyt laskimeen luvun (\d+)/ do |n|
  @laskin.pinoa n.to_i
end

When /painan "(\w+)"/ do |op|
  @tulos = @laskin.send op
end

Then /laskimen ruudulla pitäisi näkyä tulos (.*)/ do |tulos|
  @tulos.should == tulos.to_f
end

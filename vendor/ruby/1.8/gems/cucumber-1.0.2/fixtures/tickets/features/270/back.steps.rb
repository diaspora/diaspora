begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Given /^plop$/ do
  raise "Only one plop!" if @plop
  @plop = true
end
 
When /^I barp$/ do
  @plop.should == true
end
 
When /^I wibble$/ do
  @plop.should == true
end
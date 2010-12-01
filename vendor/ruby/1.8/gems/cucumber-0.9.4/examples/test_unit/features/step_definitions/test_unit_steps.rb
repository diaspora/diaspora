require 'test/unit/assertions'
World(Test::Unit::Assertions)

Given /^(\w+) = (\w+)$/ do |var, value|
  instance_variable_set("@#{var}", value)
end

begin
  require 'rubygems'
  require 'matchy'
  Then /^I can assert that (\w+) == (\w+)$/ do |var_a, var_b|
    a = instance_variable_get("@#{var_a}")
    b = instance_variable_get("@#{var_b}")
    a.should == b
  end
rescue LoadError
  STDERR.puts "***** You should install matchy *****"
  Then /^I can assert that (\w+) == (\w+)$/ do |var_a, var_b|
    a = instance_variable_get("@#{var_a}")
    b = instance_variable_get("@#{var_b}")
    assert_equal(a, b)
  end
end
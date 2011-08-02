begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Given /^I fail$/ do
  raise "BOOM (this is expected)"
end

Given /^I pass$/ do
end

module HookChecks
  def check_failed(scenario)
    scenario.should be_failed
    scenario.should_not be_passed
    scenario.exception.message.should == "BOOM (this is expected)"
  end

  def check_undefined(scenario)
    scenario.should_not be_failed
    scenario.should_not be_passed
  end

  def check_passed(scenario)
    scenario.should_not be_failed
    scenario.should be_passed
  end
end

World(HookChecks)

After('@272_failed') do |scenario|
  check_failed(scenario)
end

After('@272_undefined') do |scenario|
  check_undefined(scenario)
end

After('@272_passed') do |scenario|
  check_passed(scenario)
end

counter = 0
After('@272_outline') do |scenario|
  case(counter)
    when 0
      check_failed(scenario)
    when 1
      check_undefined(scenario)
    when 2
      check_passed(scenario)
  end
  counter +=1
end
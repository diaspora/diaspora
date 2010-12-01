def flunker
  raise "FAIL"
end

Given(/^passing$/) do |table| end


Given /^failing$/ do |string| x=1
  flunker
end

Given(/^passing without a table$/) do end


Given /^failing without a table$/ do x=1
  flunker
end

Given /^a step definition that calls an undefined step$/ do Given 'this does not exist'
end


Given /^call step "(.*)"$/ do |step| x=1
  Given step
end

Given /^'(.+)' cukes$/ do |cukes| x=1
  raise "We already have #{@cukes} cukes!" if @cukes
  @cukes = cukes
end
Then /^I should have '(.+)' cukes$/ do |cukes| x=1
  @cukes.should == cukes
end

Given /^'(.+)' global cukes$/ do |cukes| x=1
  $scenario_runs ||= 0
  flunker if $scenario_runs >= 1
  $cukes = cukes
  $scenario_runs += 1
end

Then /^I should have '(.+)' global cukes$/ do |cukes| x=1
  $cukes.should == cukes
end

Given /^table$/ do |table| x=1
  @table = table
end

Given /^multiline string$/ do |string| x=1
  @multiline = string
end

Then /^the table should be$/ do |table| x=1
  @table.raw.should == table.raw
end

Then /^the multiline string should be$/ do |string| x=1
  @multiline.should == string
end

Given /^failing expectation$/ do x=1
  'this'.should == 'that'
end

Given(/^unused$/) do end


Given(/^another unused$/) do end


require 'fileutils'

after_file = File.expand_path(File.dirname(__FILE__) + '/../../tmp/after.txt')

Before do
  FileUtils.rm(after_file) if File.exist?(after_file)
end

After('@after_file') do
  FileUtils.mkdir_p(File.dirname(after_file))
  FileUtils.touch(after_file)
end


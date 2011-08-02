#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Given /^a configuration class '(.+)'$/ do |classname|
end

When /^I set '(.+)' to '(.+)' in configuration class '(.+)'$/ do |key, value, classname|

  #ConfigIt[key.to_sym] = value
  if classname == 'ConfigIt'
    ConfigIt[key.to_sym] = value
  elsif classname == 'ConfigItToo'
    ConfigItToo[key.to_sym] = value
  else
    raise ArgumentError, "configuration class must be ConfigIt or ConfigItToo"
  end 
end

Then /^config option '(.+)' is '(.+)'$/ do |key, value|
  ConfigIt[key.to_sym].should == value
end

Then /^in configuration class '(.+)' config option '(.+)' is '(.+)'$/ do |classname, key, value|
  if classname == 'ConfigIt'
    ConfigIt[key.to_sym].should == value 
  elsif classname == 'ConfigItToo'
    ConfigItToo[key.to_sym].should == value 
  else
    raise ArgumentError, "configuration class must be ConfigIt or ConfigItToo"
  end 
end

When /^I set '(.+)' to:$/ do |key, foo_table|
  ConfigIt[key.to_sym] = Array.new
  foo_table.hashes.each do |hash|
    ConfigIt[key.to_sym] << hash['key']
  end
end

Then /^an array is returned for '(.+)'$/ do |key|
  ConfigIt[key.to_sym].should be_a_kind_of(Array)
end

Given /^a configuration file '(.+)'$/ do |filename|
  @config_file = File.join(File.dirname(__FILE__), "..", "support", filename)
end

When /^I load the configuration$/ do
  ConfigIt.from_file(@config_file)
end


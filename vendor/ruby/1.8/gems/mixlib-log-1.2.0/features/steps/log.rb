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

Given /^a base log level of '(.+)'$/ do |level|
  Logit.level = level.to_sym
end

When /^the message '(.+)' is sent at the '(.+)' level$/ do |message, level|
  case level.to_sym
  when :debug
    Logit.debug(message)
  when :info
    Logit.info(message)
  when :warn
    Logit.warn(message)
  when :error
    Logit.error(message)
  when :fatal
    Logit.fatal(message)
  else
    raise ArgumentError, "Level is not one of debug, info, warn, error, or fatal"
  end
end

Then /^the regex '(.+)' should be logged$/ do |regex_string|  
  regex = Regexp.new(regex_string, Regexp::MULTILINE)
  regex.match(@output).should_not == nil
end

Then /^nothing should be logged$/ do 
  @output.should == ""
end


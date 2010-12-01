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

require 'time'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

describe Mixlib::Log::Formatter do
  before(:each) do
    @formatter = Mixlib::Log::Formatter.new
  end
  
  it "should print raw strings with msg2str(string)" do
    @formatter.msg2str("nuthin new").should == "nuthin new"
  end
  
  it "should format exceptions properly with msg2str(e)" do
    e = IOError.new("legendary roots crew")
    @formatter.msg2str(e).should == "legendary roots crew (IOError)\n"
  end
  
  it "should format random objects via inspect with msg2str(Object)" do
    @formatter.msg2str([ "black thought", "?uestlove" ]).should == '["black thought", "?uestlove"]'
  end
  
  it "should return a formatted string with call" do
    time = Time.new
    Mixlib::Log::Formatter.show_time = true
    @formatter.call("monkey", time, "test", "mos def").should == "[#{time.rfc2822}] monkey: mos def\n"
  end
  
  it "should allow you to turn the time on and off in the output" do
    Mixlib::Log::Formatter.show_time = false
    @formatter.call("monkey", Time.new, "test", "mos def").should == "monkey: mos def\n"
  end
  
end
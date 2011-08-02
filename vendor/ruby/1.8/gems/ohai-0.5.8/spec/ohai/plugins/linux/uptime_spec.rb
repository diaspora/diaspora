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


require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "Linux plugin uptime" do
  before(:each) do
    @ohai = Ohai::System.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:os] = "linux"
    @ohai._require_plugin("uptime")
    @mock_file = mock("/proc/uptime", { :gets => "18423 989" })
    File.stub!(:open).with("/proc/uptime").and_return(@mock_file)
  end
 
  it "should check /proc/uptime for the uptime and idletime" do
    File.should_receive(:open).with("/proc/uptime").and_return(@mock_file)
    @ohai._require_plugin("linux::uptime")
  end
  
  it "should split the value of /proc uptime" do
    @mock_file.gets.should_receive(:split).with(" ").and_return(["18423", "989"])
    @ohai._require_plugin("linux::uptime")
  end
  
  it "should set uptime_seconds to uptime" do
    @ohai._require_plugin("linux::uptime")
    @ohai[:uptime_seconds].should == 18423
  end
  
  it "should set uptime to a human readable date" do
    @ohai._require_plugin("linux::uptime")
    @ohai[:uptime].should == "5 hours 07 minutes 03 seconds"
  end
  
  it "should set idletime_seconds to uptime" do
    @ohai._require_plugin("linux::uptime")
    @ohai[:idletime_seconds].should == 989
  end
  
  it "should set idletime to a human readable date" do
    @ohai._require_plugin("linux::uptime")
    @ohai[:idletime].should == "16 minutes 29 seconds"
  end
end
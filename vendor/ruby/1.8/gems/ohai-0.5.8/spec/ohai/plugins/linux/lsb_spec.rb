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

describe Ohai::System, "Linux lsb plugin" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:os] = "linux"    
    @ohai.stub!(:require_plugin).and_return(true)
    @mock_file = mock("/etc/lsb-release")
    @mock_file.stub!(:each).
      and_yield("DISTRIB_ID=Ubuntu").
      and_yield("DISTRIB_RELEASE=8.04").
      and_yield("DISTRIB_CODENAME=hardy").
      and_yield('DISTRIB_DESCRIPTION="Ubuntu 8.04"')
    File.stub!(:open).with("/etc/lsb-release").and_return(@mock_file)
  end
  
  it "should set lsb[:id]" do
    @ohai._require_plugin("linux::lsb")
    @ohai[:lsb][:id].should == "Ubuntu"
  end
  
  it "should set lsb[:release]" do
    @ohai._require_plugin("linux::lsb")
    @ohai[:lsb][:release].should == "8.04"
  end
  
  it "should set lsb[:codename]" do
    @ohai._require_plugin("linux::lsb")
    @ohai[:lsb][:codename].should == "hardy"
  end
  
  it "should set lsb[:description]" do
    @ohai._require_plugin("linux::lsb")
    @ohai[:lsb][:description].should == "\"Ubuntu 8.04\""
  end
  
  it "should not set any lsb values if /etc/lsb-release cannot be read" do
    File.stub!(:open).with("/etc/lsb-release").and_raise(IOError)
    @ohai.attribute?(:lsb).should be(false)
  end
end
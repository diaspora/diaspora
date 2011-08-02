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

describe Ohai::System, "NetBSD plugin platform" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai.stub!(:from).with("uname -s").and_return("NetBSD")
    @ohai.stub!(:from).with("uname -r").and_return("4.5")
    @ohai[:os] = "netbsd"
  end

  it "should set platform to lowercased lsb[:id]" do
    @ohai._require_plugin("netbsd::platform")
    @ohai[:platform].should == "netbsd"
  end

  it "should set platform_version to lsb[:release]" do
    @ohai._require_plugin("netbsd::platform")
    @ohai[:platform_version].should == "4.5"
  end
end

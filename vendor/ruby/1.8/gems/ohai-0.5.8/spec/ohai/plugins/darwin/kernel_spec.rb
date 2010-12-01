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

describe Ohai::System, "Darwin kernel plugin" do
  before(:each) do
    @ohai = Ohai::System.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:kernel] = Mash.new
    @ohai[:kernel][:name] = "darwin"
  end
  
  it "should not set kernel_machine to x86_64" do
    @ohai.stub!(:from).with("sysctl -n hw.optional.x86_64").and_return("0")
    @ohai._require_plugin("darwin::kernel")
    @ohai[:kernel][:machine].should_not == 'x86_64'
  end
  
  it "should set kernel_machine to x86_64" do
    @ohai.stub!(:from).with("sysctl -n hw.optional.x86_64").and_return("1")
    @ohai._require_plugin("darwin::kernel")
    @ohai[:kernel][:machine].should == 'x86_64'
  end
  
  it "should set the kernel_os to the kernel_name value" do
    @ohai._require_plugin("darwin::kernel")
    @ohai[:kernel][:os].should == @ohai[:kernel][:name]
  end
end
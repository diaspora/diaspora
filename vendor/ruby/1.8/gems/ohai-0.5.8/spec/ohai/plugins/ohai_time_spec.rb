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


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Ohai::System, "plugin ohai_time" do
  before(:each) do
    @ohai = Ohai::System.new    
    @ohai.stub!(:require_plugin).and_return(true)
  end
  
  it "should get the current time" do
    Time.should_receive(:now)
    @ohai._require_plugin("ohai_time")
  end
  
  it "should turn the time into a floating point number" do
    time = Time.now
    time.should_receive(:to_f)
    Time.stub!(:now).and_return(time)
    @ohai._require_plugin("ohai_time")
  end
  
  it "should set ohai_time to the current time" do
    time = Time.now
    Time.stub!(:now).and_return(time)
    @ohai._require_plugin("ohai_time")
    @ohai[:ohai_time].should == time.to_f    
  end
end
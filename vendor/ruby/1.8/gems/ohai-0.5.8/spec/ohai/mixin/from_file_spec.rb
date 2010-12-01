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

describe Ohai::System, "from_file" do
  before(:each) do
    @ohai = Ohai::System.new
    File.stub!(:exists?).and_return(true)
    File.stub!(:readable?).and_return(true)
    IO.stub!(:read).and_return("king 'herod'")
  end
  
  it "should check to see that the file exists" do
    File.should_receive(:exists?).and_return(true)
    @ohai.from_file("/tmp/foo")
  end
  
  it "should check to see that the file is readable" do
    File.should_receive(:readable?).and_return(true)
    @ohai.from_file("/tmp/foo")
  end
  
  it "should actually read the file" do
    IO.should_receive(:read).and_return("king 'herod'")
    @ohai.from_file("/tmp/foo")
  end
  
  it "should call instance_eval with the contents of the file, file name, and line 1" do
    @ohai.should_receive(:instance_eval).with("king 'herod'", "/tmp/foo", 1)
    @ohai.from_file("/tmp/foo")
  end
  
  it "should raise an IOError if it cannot read the file" do
    File.stub!(:exists?).and_return(false)
    lambda { @ohai.from_file("/tmp/foo") }.should raise_error(IOError)
  end
end

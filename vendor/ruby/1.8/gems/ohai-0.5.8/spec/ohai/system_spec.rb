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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Ohai::System, "initialize" do
  it "should return an Ohai::System object" do
    Ohai::System.new.should be_a_kind_of(Ohai::System)
  end
  
  it "should set @data to a Mash" do
    Ohai::System.new.data.should be_a_kind_of(Mash)
  end
  
  it "should set @seen_plugins to a Hash" do
    Ohai::System.new.seen_plugins.should be_a_kind_of(Hash)
  end
end

describe Ohai::System, "method_missing" do
  before(:each) do
    @ohai = Ohai::System.new
  end
  
  it "should take a missing method and store the method name as a key, with its arguments as values" do
    @ohai.guns_n_roses("chinese democracy")
    @ohai.data["guns_n_roses"].should eql("chinese democracy")
  end
  
  it "should return the current value of the method name" do
    @ohai.guns_n_roses("chinese democracy").should eql("chinese democracy")
  end
  
  it "should allow you to get the value of a key by calling method_missing with no arguments" do
    @ohai.guns_n_roses("chinese democracy")
    @ohai.guns_n_roses.should eql("chinese democracy")
  end
end

describe Ohai::System, "attribute?" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.metallica("death magnetic")
  end
  
  it "should return true if an attribute exists with the given name" do
    @ohai.attribute?("metallica").should eql(true)
  end
  
  it "should return false if an attribute does not exist with the given name" do
    @ohai.attribute?("alice in chains").should eql(false)
  end
end

describe Ohai::System, "set_attribute" do
  before(:each) do
    @ohai = Ohai::System.new
  end
  
  it "should let you set an attribute" do
    @ohai.set_attribute(:tea, "is soothing")
    @ohai.data["tea"].should eql("is soothing")
  end 
end

describe Ohai::System, "get_attribute" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.set_attribute(:tea, "is soothing")
  end
  
  it "should let you get an attribute" do
    @ohai.get_attribute("tea").should eql("is soothing")
  end 
end

describe Ohai::System, "require_plugin" do
  tmp = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || '/tmp'

  before(:each) do
    @plugin_path = Ohai::Config[:plugin_path]
    Ohai::Config[:plugin_path] = ["#{tmp}/plugins"]
    File.stub!(:exists?).and_return(true)
    @ohai = Ohai::System.new
    @ohai.stub!(:from_file).and_return(true)
  end

  after(:each) do
    Ohai::Config[:plugin_path] = @plugin_path
  end
  
  it "should convert the name of the plugin to a file path" do
    plugin_name = "foo::bar"
    plugin_name.should_receive(:gsub).with("::", File::SEPARATOR)
    @ohai.require_plugin(plugin_name)
  end
  
  it "should check each part of the Ohai::Config[:plugin_path] for the plugin_filename.rb" do
    @ohai.should_receive(:from_file).with(File.expand_path("#{tmp}/plugins/foo.rb")).and_return(true)
    @ohai.require_plugin("foo")
  end
  
  it "should add a found plugin to the list of seen plugins" do
    @ohai.require_plugin("foo")
    @ohai.seen_plugins["foo"].should eql(true)
  end
  
  it "should return true if the plugin has been seen" do
    @ohai.seen_plugins["foo"] = true
    @ohai.require_plugin("foo")
  end
  
  it "should return true if the plugin has been loaded" do
    @ohai.require_plugin("foo").should eql(true)
  end

  it "should return false if the plugin is in the disabled plugins list" do
    Ohai::Config[:disabled_plugins] = [ "foo" ]
    Ohai::Log.should_receive(:debug).with("Skipping disabled plugin foo")
    @ohai.require_plugin("foo").should eql(false)
  end
end


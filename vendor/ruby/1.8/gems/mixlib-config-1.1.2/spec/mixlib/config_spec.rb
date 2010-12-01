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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

class ConfigIt
  extend ::Mixlib::Config
end


describe Mixlib::Config do
  before(:each) do
    ConfigIt.configure do |c|
      c[:alpha] = 'omega'
      c[:foo] = nil
    end
  end
  
  it "should load a config file" do
    File.stub!(:exists?).and_return(true)
    File.stub!(:readable?).and_return(true)
    IO.stub!(:read).with('config.rb').and_return("alpha = 'omega'\nfoo = 'bar'")
    lambda { 
      ConfigIt.from_file('config.rb')
    }.should_not raise_error
  end
  
  it "should not raise an ArgumentError with an explanation if you try and set a non-existent variable" do
    lambda { 
      ConfigIt[:foobar] = "blah"
    }.should_not raise_error(ArgumentError)
  end
  
  it "should raise an Errno::ENOENT if it can't find the file" do
    lambda { 
      ConfigIt.from_file("/tmp/timmytimmytimmy")
    }.should raise_error(Errno::ENOENT)
  end

  it "should allow the error to bubble up when it's anything other than IOError" do
    IO.stub!(:read).with('config.rb').and_return("@#asdf")
    lambda {
      ConfigIt.from_file('config.rb')
    }.should raise_error(SyntaxError)
  end
  
  it "should allow you to reference a value by index" do
    ConfigIt[:alpha].should == 'omega'
  end
  
  it "should allow you to set a value by index" do
    ConfigIt[:alpha] = "one"
    ConfigIt[:alpha].should == "one"
  end

  it "should allow setting a value with attribute form" do
    ConfigIt.arbitrary_value = 50
    ConfigIt.arbitrary_value.should == 50
    ConfigIt[:arbitrary_value].should == 50
  end
  
  describe "when a block has been used to set config values" do
    before do
      ConfigIt.configure { |c| c[:cookbook_path] = "monkey_rabbit"; c[:otherthing] = "boo" }
    end
    
    {:cookbook_path => "monkey_rabbit", :otherthing => "boo"}.each do |k,v|
      it "should allow you to retrieve the config value for #{k} via []" do
        ConfigIt[k].should == v
      end
      it "should allow you to retrieve the config value for #{k} via method_missing" do
        ConfigIt.send(k).should == v
      end
    end
  end
  
  it "should not raise an ArgumentError if you access a config option that does not exist" do
    lambda { ConfigIt[:snob_hobbery] }.should_not raise_error(ArgumentError)
  end
  
  it "should return true or false with has_key?" do
    ConfigIt.has_key?(:monkey).should eql(false)
    ConfigIt[:monkey] = "gotcha"
    ConfigIt.has_key?(:monkey).should eql(true)
  end
  
  describe "when a class method override accessor exists" do
    before do
      @klass = Class.new
      @klass.extend(::Mixlib::Config)
      @klass.class_eval(<<-EVAL)
        config_attr_writer :test_method do |blah|
          blah.is_a?(Integer) ? blah * 1000 : blah
        end
        pp self.methods
      EVAL
    end

    it "should multiply an integer by 1000" do
      @klass[:test_method] = 53
      @klass[:test_method].should == 53000
    end

    it "should multiply an integer by 1000 with the method_missing form" do
      @klass.test_method = 63
      @klass.test_method.should == 63000
    end

    it "should multiply an integer by 1000 with the instance_eval DSL form" do
      @klass.instance_eval("test_method 73")
      @klass.test_method.should == 73000
    end

    it "should multiply an integer by 1000 via from-file, too" do
      IO.stub!(:read).with('config.rb').and_return("test_method 99")
      @klass.from_file('config.rb')
      @klass.test_method.should == 99000
    end
    
    it "should receive internal_set with the method name and config value" do
      @klass.should_receive(:internal_set).with(:test_method, 53).and_return(true)
      @klass[:test_method] = 53
    end
    
  end
end

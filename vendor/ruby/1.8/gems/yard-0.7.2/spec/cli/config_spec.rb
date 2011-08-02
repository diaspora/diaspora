require File.dirname(__FILE__) + '/../spec_helper'

require 'yaml'

describe YARD::CLI::Config do
  before do
    @config = YARD::CLI::Config.new
    YARD::Config.options = YARD::Config::DEFAULT_CONFIG_OPTIONS.dup
    YARD::Config.stub!(:save)
  end
  
  def run(*args)
    @config.run(*args)
  end
  
  describe 'Listing configuration' do
    it "should accept --list" do
      opts = YARD::Config.options
      YAML.should_receive(:dump).twice.and_return("--- foo\nbar\nbaz")
      @config.should_receive(:puts).twice.with("bar\nbaz")
      run
      run('--list')
      YARD::Config.options.should == opts
    end
  end
  
  describe 'Viewing an item' do
    it "should view item if no value is given" do
      YARD::Config.options[:foo] = 'bar'
      @config.should_receive(:puts).with('"bar"')
      run 'foo'
      YARD::Config.options[:foo].should == 'bar'
    end
  end
  
  describe 'Modifying an item' do
    it "should accept --reset to set value" do
      YARD::Config.options[:load_plugins] = 'foo'
      run('--reset', 'load_plugins')
      YARD::Config.options[:load_plugins].should == false
    end
    
    it "should accept --as-list to force single item as list" do
      run('--as-list', 'foo', 'bar')
      YARD::Config.options[:foo].should == ['bar']
    end
    
    it "should accept --append to append values to existing key" do
      YARD::Config.options[:foo] = ['bar']
      run('--append', 'foo', 'baz', 'quux')
      YARD::Config.options[:foo].should == ['bar', 'baz', 'quux']
      run('-a', 'foo', 'last')
      YARD::Config.options[:foo].should == ['bar', 'baz', 'quux', 'last']
    end
    
    it "should turn key into list if --append is used on single item" do
      YARD::Config.options[:foo] = 'bar'
      run('-a', 'foo', 'baz')
      YARD::Config.options[:foo].should == ['bar', 'baz']
    end
    
    it "should modify item if value is given" do
      run('foo', 'xxx')
      YARD::Config.options[:foo].should == 'xxx'
    end
    
    it "should turn list of values into array of values" do
      run('foo', 'a', 'b', '1', 'true', 'false')
      YARD::Config.options[:foo].should == ['a', 'b', 1, true, false]
    end
    
    it "should turn number into numeric Ruby type" do
      run('foo', '1')
      YARD::Config.options[:foo].should == 1
    end
    
    it "should turn true into TrueClass" do
      run('foo', 'true')
      YARD::Config.options[:foo].should == true
    end
    
    it "should turn false into FalseClass" do
      run('foo', 'false')
      YARD::Config.options[:foo].should == false
    end
    
    it "should save on modification" do
      YARD::Config.should_receive(:save)
      run('foo', 'true')
    end
  end
end
require File.dirname(__FILE__) + '/../spec_helper'

class YARD::CLI::YRI
  public :optparse, :find_object, :cache_object
end

describe YARD::CLI::Yardoc do
  before do
    @yri = YARD::CLI::YRI.new
    Registry.stub!(:load)
  end
  
  describe '#find_object' do
    it "should use cache if available" do
      @yri.stub!(:cache_object)
      File.should_receive(:exist?).with('.yardoc').and_return(false)
      File.should_receive(:exist?).with('bar.yardoc').and_return(true)
      Registry.should_receive(:load).with('bar.yardoc')
      Registry.should_receive(:at).with('Foo').and_return('OBJ')
      @yri.instance_variable_set("@cache", {'Foo' => 'bar.yardoc'})
      @yri.find_object('Foo').should == 'OBJ'
    end
    
    it "should never use cache ahead of current directory's .yardoc" do
      @yri.stub!(:cache_object)
      File.should_receive(:exist?).with('.yardoc').and_return(true)
      Registry.should_receive(:load).with('.yardoc')
      Registry.should_receive(:at).with('Foo').and_return('OBJ')
      @yri.instance_variable_set("@cache", {'Foo' => 'bar.yardoc'})
      @yri.find_object('Foo').should == 'OBJ'
      @yri.instance_variable_get("@search_paths")[0].should == '.yardoc'
    end
  end
  
  describe '#cache_object' do
    it "should skip caching for Registry.yardoc_file" do
      File.should_not_receive(:open).with(CLI::YRI::CACHE_FILE, 'w')
      @yri.cache_object('Foo', Registry.yardoc_file)
    end
  end
  
  describe '#initialize' do
    it "should load search paths" do
      path = %r{/\.yard/yri_search_paths$}
      File.should_receive(:file?).with(%r{/\.yard/yri_cache$}).and_return(false)
      File.should_receive(:file?).with(path).and_return(true)
      File.should_receive(:readlines).with(path).and_return(%w(line1 line2))
      @yri = YARD::CLI::YRI.new
      spaths = @yri.instance_variable_get("@search_paths")
      spaths.should include('line1')
      spaths.should include('line2')
    end
    
    it "should use DEFAULT_SEARCH_PATHS prior to other paths" do
      YARD::CLI::YRI::DEFAULT_SEARCH_PATHS.push('foo', 'bar')
      path = %r{/\.yard/yri_search_paths$}
      File.should_receive(:file?).with(%r{/\.yard/yri_cache$}).and_return(false)
      File.should_receive(:file?).with(path).and_return(true)
      File.should_receive(:readlines).with(path).and_return(%w(line1 line2))
      @yri = YARD::CLI::YRI.new
      spaths = @yri.instance_variable_get("@search_paths")
      spaths[0,4].should == %w(foo bar line1 line2)
      YARD::CLI::YRI::DEFAULT_SEARCH_PATHS.replace([])
    end
  end
  
  describe '#run' do
    it "should search for objects and print their documentation" do
      obj = YARD::CodeObjects::ClassObject.new(:root, 'Foo')
      @yri.should_receive(:print_object).with(obj)
      @yri.run('Foo')
      Registry.clear
    end
    
    it "should print usage if no object is provided" do
      @yri.should_receive(:print_usage)
      @yri.should_receive(:exit).with(1)
      @yri.run('')
    end
    
    it "should print no documentation exists for object if object is not found" do
      STDERR.should_receive(:puts).with("No documentation for `Foo'")
      @yri.should_receive(:exit).with(1)
      @yri.run('Foo')
    end
  end
end

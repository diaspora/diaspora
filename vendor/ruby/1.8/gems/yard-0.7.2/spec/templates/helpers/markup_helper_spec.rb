require File.dirname(__FILE__) + '/../../spec_helper'

module YARD::Templates::Helpers::MarkupHelper
  public :load_markup_provider, :markup_class, :markup_provider
end

class GeneratorMock
  attr_accessor :options
  include YARD::Templates::Helpers::MarkupHelper
  def initialize(options = {}) self.options = options end
end

describe YARD::Templates::Helpers::MarkupHelper do
  before do
    YARD::Templates::Helpers::MarkupHelper.clear_markup_cache
  end
  
  describe '#load_markup_provider' do
    before do
      log.stub!(:error)
      @gen = GeneratorMock.new
    end
  
    it "should exit on an invalid markup type" do
      @gen.options = {:markup => :invalid}
      @gen.load_markup_provider.should == false
    end

    it "should fail on when an invalid markup provider is specified" do
      @gen.stub!(:options).and_return({:markup => :markdown, :markup_provider => :invalid})
      @gen.load_markup_provider.should == false
      @gen.markup_class.should == nil
    end
  
    it "should load RDocMarkup if rdoc is specified and it is installed" do
      @gen.stub!(:options).and_return({:markup => :rdoc})
      @gen.load_markup_provider.should == true
      @gen.markup_class.should == YARD::Templates::Helpers::Markup::RDocMarkup
    end
    
    it "should fail if RDoc cannot be loaded" do
      @gen.stub!(:options).and_return({:markup => :rdoc})
      @gen.should_receive(:eval).with('::YARD::Templates::Helpers::Markup::RDocMarkup').and_raise(NameError)
      @gen.load_markup_provider.should == false
      @gen.markup_provider.should == nil
    end
  
    it "should search through available markup providers for the markup type if none is set" do
      @gen.should_receive(:eval).with('::RDiscount').and_return(mock(:bluecloth))
      @gen.should_receive(:require).with('rdiscount').and_return(true)
      @gen.should_not_receive(:require).with('maruku')
      @gen.stub!(:options).and_return({:markup => :markdown})
      # this only raises an exception because we mock out require to avoid 
      # loading any libraries but our implementation tries to return the library 
      # name as a constant
      @gen.load_markup_provider.should == true
      @gen.markup_provider.should == :rdiscount
    end
  
    it "should continue searching if some of the providers are unavailable" do
      @gen.should_receive(:require).with('rdiscount').and_raise(LoadError)
      @gen.should_receive(:require).with('kramdown').and_raise(LoadError)
      @gen.should_receive(:require).with('bluecloth').and_raise(LoadError)
      @gen.should_receive(:require).with('maruku').and_raise(LoadError)
      @gen.should_receive(:require).with('redcarpet').and_raise(LoadError)
      @gen.should_receive(:require).with('rpeg-markdown').and_return(true)
      @gen.should_receive(:eval).with('::PEGMarkdown').and_return(true)
      @gen.stub!(:options).and_return({:markup => :markdown})
      # this only raises an exception because we mock out require to avoid 
      # loading any libraries but our implementation tries to return the library 
      # name as a constant
      @gen.load_markup_provider.should rescue nil
      @gen.markup_provider.should == :"rpeg-markdown"
    end
  
    it "should override the search if `:markup_provider` is set in options" do
      @gen.should_receive(:require).with('rdiscount').and_return(true)
      @gen.should_receive(:eval).with('::RDiscount').and_return(true)
      @gen.stub!(:options).and_return({:markup => :markdown, :markup_provider => :rdiscount})
      @gen.load_markup_provider.should rescue nil
      @gen.markup_provider.should == :rdiscount
    end

    it "should fail if no provider is found" do
      YARD::Templates::Helpers::MarkupHelper::MARKUP_PROVIDERS[:markdown].each do |p|
        @gen.should_receive(:require).with(p[:lib].to_s).and_raise(LoadError)
      end
      @gen.stub!(:options).and_return({:markup => :markdown})
      @gen.load_markup_provider.should == false
      @gen.markup_provider.should == nil
    end

    it "should fail if overridden provider is not found" do
      @gen.should_receive(:require).with('rdiscount').and_raise(LoadError)
      @gen.stub!(:options).and_return({:markup => :markdown, :markup_provider => :rdiscount})
      @gen.load_markup_provider.should == false
      @gen.markup_provider.should == nil
    end
    
    it "should fail if the markup type is not found" do
      log.should_receive(:error).with(/Invalid markup/)
      @gen.stub!(:options).and_return(:markup => :xxx)
      @gen.load_markup_provider.should == false
      @gen.markup_provider.should == nil
    end
  end
  
  describe '#markup_for_file' do
    include YARD::Templates::Helpers::MarkupHelper

    it "should look for a shebang line" do
      markup_for_file("#!text\ntext here", 'file.rdoc').should == :text
    end
    
    it "should return the default markup type if no shebang is found or no valid ext is found" do
      stub!(:options).and_return({:markup => :default_type})
      markup_for_file('', 'filename').should == :default_type
    end
    
    it "should look for a file extension if no shebang is found" do
      markup_for_file('', 'filename.MD').should == :markdown
    end
    
    Templates::Helpers::MarkupHelper::MARKUP_EXTENSIONS.each do |type, exts|
      exts.each do |ext|
        it "should recognize .#{ext} as #{type} markup type" do
          markup_for_file('', "filename.#{ext}").should == type
        end
      end
    end
  end
end

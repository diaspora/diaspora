require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Templates::Helpers::BaseHelper do
  include YARD::Templates::Helpers::BaseHelper
  
  describe '#run_verifier' do
    it "should run verifier proc against list if provided" do
      mock = Verifier.new
      mock.should_receive(:call).with(1)
      mock.should_receive(:call).with(2)
      mock.should_receive(:call).with(3)
      should_receive(:options).at_least(1).times.and_return(:verifier => mock)
      run_verifier [1, 2, 3]      
    end
    
    it "should prune list if lambda returns false and only false" do
      mock = Verifier.new
      should_receive(:options).at_least(1).times.and_return(:verifier => mock)
      mock.should_receive(:call).with(1).and_return(false)
      mock.should_receive(:call).with(2).and_return(true)
      mock.should_receive(:call).with(3).and_return(nil)
      mock.should_receive(:call).with(4).and_return("value")
      run_verifier([1, 2, 3, 4]).should == [2, 3, 4]
    end
    
    it "should return list if no verifier exists" do
      should_receive(:options).at_least(1).times.and_return({})
      run_verifier([1, 2, 3]).should == [1, 2, 3]
    end
  end
  
  describe '#h' do
    it "should return just the text" do
      h("hello world").should == "hello world"
      h(nil).should == nil
    end
  end
  
  describe '#link_object' do
    it "should return the title if provided" do
      link_object(1, "title").should == "title"
      link_object(Registry.root, "title").should == "title"
    end
    
    it "should return a path if argument is a Proxy or object" do
      link_object(Registry.root).should == ""
      link_object(P("Array")).should == "Array"
    end
    
    it "should should return path of Proxified object if argument is a String or Symbol" do
      link_object("Array").should == "Array"
      link_object(:"A::B").should == "A::B"
    end
    
    it "should return the argument if not an object, proxy, String or Symbol" do
      link_object(1).should == 1
    end
  end
  
  describe '#link_url' do
    it "should return the URL" do
      link_url("http://url").should == "http://url"
    end
  end
  
  describe '#linkify' do
    before do
      stub!(:object).and_return(Registry.root)
    end
    
    it "should call #link_url for mailto: links" do
      should_receive(:link_url)
      linkify("mailto:steve@example.com")
    end
    
    it "should call #link_url for URL schemes (http://)" do
      should_receive(:link_url)
      linkify("http://example.com")
    end
    
    it "should call #link_file for file: links" do
      should_receive(:link_file).with('Filename', nil, 'anchor')
      linkify("file:Filename#anchor")
    end
    
    it "should pass off to #link_object if argument is an object" do
      obj = CodeObjects::NamespaceObject.new(nil, :YARD)
      should_receive(:link_object).with(obj)
      linkify obj
    end
    
    it "should return empty string and warn if object does not exist" do
      log.should_receive(:warn).with(/Cannot find object .* for inclusion/)
      linkify('include:NotExist').should == ''
    end
  
    it "should pass off to #link_url if argument is recognized as a URL" do
      url = "http://yardoc.org/"
      should_receive(:link_url).with(url, nil, {:target => '_parent'})
      linkify url
    end
    
    it "should call #link_include_object for include:ObjectName" do
      obj = CodeObjects::NamespaceObject.new(:root, :Foo)
      should_receive(:link_include_object).with(obj)
      linkify 'include:Foo'
    end
    
    it "should call #link_include_file for include:file:path/to/file" do
      File.should_receive(:file?).with('path/to/file').and_return(true)
      File.should_receive(:read).with('path/to/file').and_return('FOO')
      linkify('include:file:path/to/file').should == 'FOO'
    end
    
    it "should not allow include:file for path above pwd" do
      log.should_receive(:warn).with("Cannot include file from path `a/b/../../../../file'")
      linkify('include:file:a/b/../../../../file').should == ''
    end
    
    it "should warn if include:file:path does not exist" do
      log.should_receive(:warn).with(/Cannot find file .+ for inclusion/)
      linkify('include:file:notexist').should == ''
    end
  end
  
  describe '#format_types' do
    it "should return the list of types separated by commas surrounded by brackets" do
      format_types(['a', 'b', 'c']).should == '(a, b, c)'
    end
    
    it "should return the list of types without brackets if brackets=false" do
      format_types(['a', 'b', 'c'], false).should == 'a, b, c'
    end
    
    it "should should return an empty string if list is empty or nil" do
      format_types(nil).should == ""
      format_types([]).should == ""
    end
  end
  
  describe '#format_object_type' do
    it "should return Exception if type is Exception" do
      obj = mock(:object)
      obj.stub!(:is_a?).with(YARD::CodeObjects::ClassObject).and_return(true)
      obj.stub!(:is_exception?).and_return(true)
      format_object_type(obj).should == "Exception"
    end
    
    it "should return Class if type is Class" do
      obj = mock(:object)
      obj.stub!(:is_a?).with(YARD::CodeObjects::ClassObject).and_return(true)
      obj.stub!(:is_exception?).and_return(false)
      format_object_type(obj).should == "Class"
    end
    
    it "should return object type in other cases" do
      obj = mock(:object)
      obj.stub!(:type).and_return("value")
      format_object_type(obj).should == "Value"
    end
  end
  
  describe '#format_object_title' do
    it "should return Top Level Namespace for root object" do
      format_object_title(Registry.root).should == "Top Level Namespace"
    end
    
    it "should return 'type: path' in other cases" do
      obj = mock(:object)
      obj.stub!(:type).and_return(:class)
      obj.stub!(:path).and_return("A::B::C")
      format_object_title(obj).should == "Class: A::B::C"
    end
  end
end

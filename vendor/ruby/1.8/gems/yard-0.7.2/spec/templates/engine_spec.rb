require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Engine do
  describe '.register_template_path' do
    it "should register a String path" do
      Engine.register_template_path('.')
      Engine.template_paths.pop.should == '.'
    end
  end
  
  describe '.template!' do
    it "should create a module including Template" do
      mod = Engine.template!('path/to/template')
      mod.should include(Template)
      mod.full_path.to_s.should == 'path/to/template'
    end
    
    it "should create a module including Template with full_path" do
      mod = Engine.template!('path/to/template2', '/full/path/to/template2')
      mod.should include(Template)
      mod.full_path.to_s.should == '/full/path/to/template2'
    end
  end
  
  describe '.template' do
    it "should raise an error if the template is not found" do
      lambda { Engine.template(:a, :b, :c) }.should raise_error(ArgumentError)
    end
    
    it "should create a module including Template" do
      mock = mock(:template)
      Engine.should_receive(:find_template_paths).with(nil, 'template/name').and_return(['/full/path/template/name'])
      Engine.should_receive(:template!).with('template/name', ['/full/path/template/name']).and_return(mock)
      Engine.template('template/name').should == mock
    end
    
    it "should create a Template from a relative Template path" do
      Engine.should_receive(:template_paths).and_return([])
      File.should_receive(:directory?).with("/full/path/template/notname").and_return(true)
      start_template = mock(:start_template)
      start_template.stub!(:full_path).and_return('/full/path/template/name')
      start_template.stub!(:full_paths).and_return(['/full/path/template/name'])
      start_template.should_receive(:is_a?).with(Template).and_return(true)
      mod = Engine.template(start_template, '..', 'notname')
      mod.should include(Template)
      mod.full_path.to_s.should == "/full/path/template/notname"
    end

    it "should create a Template including other matching templates in path" do
      paths = ['/full/path/template/name', '/full/path2/template/name']
      Engine.should_receive(:find_template_paths).with(nil, 'template').at_least(1).times.and_return([])
      Engine.should_receive(:find_template_paths).with(nil, 'template/name').and_return(paths)
      ancestors = Engine.template('template/name').ancestors.map {|m| m.class_name }
      ancestors.should include("Template__full_path2_template_name")
    end
    
    it "should include parent directories before other template paths" do
      paths = ['/full/path/template/name', '/full/path2/template/name']
      Engine.should_receive(:find_template_paths).with(nil, 'template/name').and_return(paths)
      ancestors = Engine.template('template/name').ancestors.map {|m| m.class_name }
      ancestors[0, 4].should == ["Template__full_path_template_name", "Template__full_path_template", 
        "Template__full_path2_template_name", "Template__full_path2_template"]
    end
  end
  
  describe '.generate' do
    it "should generate with fulldoc template" do
      mod = mock(:template)
      mod.should_receive(:run).with(:__globals => OpenStruct.new, :format => :text, :template => :default, :objects => [:a, :b, :c])
      Engine.should_receive(:template).with(:default, :fulldoc, :text).and_return(mod)
      Engine.generate([:a, :b, :c])
    end
  end
  
  describe '.render' do
    def loads_template(*args)
      Engine.should_receive(:template).with(*args).and_return(@template)
    end
  
    before(:all) do 
      @object = CodeObjects::MethodObject.new(:root, :method)
    end
    
    before do
      @template = mock(:template)
      @template.stub!(:include)
    end
  
    it "should accept method call with no parameters" do
      loads_template(:default, :method, :text)
      @template.should_receive(:run).with :__globals => OpenStruct.new,
                                          :type => :method,
                                          :template => :default,
                                          :format => :text,
                                          :object => @object
      @object.format
    end
  
    it "should allow template key to be changed" do
      loads_template(:javadoc, :method, :text)
      @template.should_receive(:run).with :__globals => OpenStruct.new,
                                          :type => :method,
                                          :template => :javadoc,
                                          :format => :text,
                                          :object => @object
      @object.format(:template => :javadoc)
    end

    it "should allow type key to be changed" do
      loads_template(:default, :fulldoc, :text)
      @template.should_receive(:run).with :__globals => OpenStruct.new,
                                          :type => :fulldoc,
                                          :template => :default,
                                          :format => :text,
                                          :object => @object
      @object.format(:type => :fulldoc)
    end
  
    it "should allow format key to be changed" do
      loads_template(:default, :method, :html)
      @template.should_receive(:run).with :__globals => OpenStruct.new,
                                          :type => :method,
                                          :template => :default,
                                          :format => :html,
                                          :object => @object
      @object.format(:format => :html)
    end
  end
end

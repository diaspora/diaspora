require 'spec_helper'

describe Factory do
  include DefinesConstants

  before do
    define_constant('User')
    define_constant('Admin', User)
    define_constant('Business')
    define_constant('Admin::Settings')
  end

  describe "defining a factory" do
    before do
      @name    = :user
      @factory = "factory"
      stub(@factory).factory_name { @name }
      @options = { :class => 'magic' }
      stub(Factory).new { @factory }
    end

    after { Factory.factories.clear }

    it "should create a new factory using the specified name and options" do
      mock(Factory).new(@name, @options) { @factory }
      Factory.define(@name, @options) {|f| }
    end

    it "should pass the factory do the block" do
      yielded = nil
      Factory.define(@name) do |y|
        yielded = y
      end
      yielded.should == @factory
    end

    it "should add the factory to the list of factories" do
      Factory.define(@name) {|f| }
      @factory.should == Factory.factories[@name]
    end

    it "should allow a factory to be found by name" do
      Factory.define(@name) {|f| }
      Factory.factory_by_name(@name).should == @factory
    end

    it "should not allow a duplicate factory definition" do
      lambda {
        2.times { Factory.define(@name) {|f| } }
      }.should raise_error(Factory::DuplicateDefinitionError)
    end

  end

  describe "a factory" do
    before do
      @name    = :user
      @class   = User
      @factory = Factory.new(@name)
    end

    it "should have a factory name" do
      @factory.factory_name.should == @name
    end

    it "should have a build class" do
      @factory.build_class.should == @class
    end

    it "should have a default strategy" do
      @factory.default_strategy.should == :create
    end

    it "should return static attribute  when asked for a type" do
      result = @factory.type
      result.should be_kind_of(Array)
      result.first.should be_kind_of(Factory::Attribute::Static)
      result.first.name.should == :type
    end

    it "should define type as an attribute" do
      @factory.type { "it's a type" }
      attributes = @factory.attributes
      attributes.should be_kind_of(Array)
      attributes.size.should == 1
      attributes.first.name.should == :type
    end

    it "should return static attribute when asked for the id" do
      result = @factory.id
      result.should be_kind_of(Array)
      result.first.should be_kind_of(Factory::Attribute::Static)
      result.first.name.should == :id
    end

    it "should define id as an attribute" do
      @factory.id { "it's an id" }
      attributes = @factory.attributes
      attributes.should be_kind_of(Array)
      attributes.size.should == 1
      attributes.first.name.should == :id
    end

    it "should not allow the same attribute to be added twice" do
      lambda {
        2.times { @factory.add_attribute :first_name }
      }.should raise_error(Factory::AttributeDefinitionError)
    end

    it "should add a static attribute when an attribute is defined with a value" do
      attribute = 'attribute'
      stub(attribute).name { :name }
      mock(Factory::Attribute::Static).new(:name, 'value') { attribute }
      @factory.add_attribute(:name, 'value')
    end

    it "should add a dynamic attribute when an attribute is defined with a block" do
      attribute = 'attribute'
      stub(attribute).name { :name }
      block     = lambda {}
      mock(Factory::Attribute::Dynamic).new(:name, block) { attribute }
      @factory.add_attribute(:name, &block)
    end

    it "should raise for an attribute with a value and a block" do
      lambda {
        @factory.add_attribute(:name, 'value') {}
      }.should raise_error(Factory::AttributeDefinitionError)
    end

    describe "adding an attribute using a in-line sequence" do
      it "should create the sequence" do
        mock(Factory::Sequence).new
        @factory.sequence(:name) {}
      end

      it "should add a dynamic attribute" do
        attribute = 'attribute'
        stub(attribute).name { :name }
        mock(Factory::Attribute::Dynamic).new(:name, is_a(Proc)) { attribute }
        @factory.sequence(:name) {}
        @factory.attributes.should include(attribute)
      end
    end

    describe "adding a callback" do
      it "should add a callback attribute when the after_build attribute is defined" do
        mock(Factory::Attribute::Callback).new(:after_build, is_a(Proc)) { 'after_build callback' }
        @factory.after_build {}
        @factory.attributes.should include('after_build callback')
      end

      it "should add a callback attribute when the after_create attribute is defined" do
        mock(Factory::Attribute::Callback).new(:after_create, is_a(Proc)) { 'after_create callback' }
        @factory.after_create {}
        @factory.attributes.should include('after_create callback')
      end

      it "should add a callback attribute when the after_stub attribute is defined" do
        mock(Factory::Attribute::Callback).new(:after_stub, is_a(Proc)) { 'after_stub callback' }
        @factory.after_stub {}
        @factory.attributes.should include('after_stub callback')
      end

      it "should add a callback attribute when defining a callback" do
        mock(Factory::Attribute::Callback).new(:after_create, is_a(Proc)) { 'after_create callback' }
        @factory.callback(:after_create) {}
        @factory.attributes.should include('after_create callback')
      end

      it "should raise an InvalidCallbackNameError when defining a callback with an invalid name" do
        lambda{
          @factory.callback(:invalid_callback_name) {}
        }.should raise_error(Factory::InvalidCallbackNameError)
      end
    end

    describe "after adding an attribute" do
      before do
        @attribute = "attribute"
        @proxy     = "proxy"

        stub(@attribute).name { :name }
        stub(@attribute).add_to
        stub(@proxy).set
        stub(@proxy).result { 'result' }
        stub(Factory::Attribute::Static).new { @attribute }
        stub(Factory::Proxy::Build).new { @proxy }

        @factory.add_attribute(:name, 'value')
      end

      it "should create the right proxy using the build class when running" do
        mock(Factory::Proxy::Build).new(@factory.build_class) { @proxy }
        @factory.run(Factory::Proxy::Build, {})
      end

      it "should add the attribute to the proxy when running" do
        mock(@attribute).add_to(@proxy)
        @factory.run(Factory::Proxy::Build, {})
      end

      it "should return the result from the proxy when running" do
        mock(@proxy).result() { 'result' }
        @factory.run(Factory::Proxy::Build, {}).should == 'result'
      end
    end

    it "should add an association without a factory name or overrides" do
      factory = Factory.new(:post)
      name    = :user
      attr    = 'attribute'
      mock(Factory::Attribute::Association).new(name, name, {}) { attr }
      factory.association(name)
      factory.attributes.should include(attr)
    end

    it "should return associations" do
      factory = Factory.new(:post)
      factory.association(:author)
      factory.association(:editor)
      factory.associations.each do |association|
        association.should be_a(Factory::Attribute::Association)
      end
      factory.associations.size.should == 2
    end

    it "should add an association with overrides" do
      factory   = Factory.new(:post)
      name      = :user
      attr      = 'attribute'
      overrides = { :first_name => 'Ben' }
      mock(Factory::Attribute::Association).new(name, name, overrides) { attr }
      factory.association(name, overrides)
      factory.attributes.should include(attr)
    end

    it "should add an association with a factory name" do
      factory = Factory.new(:post)
      attr = 'attribute'
      mock(Factory::Attribute::Association).new(:author, :user, {}) { attr }
      factory.association(:author, :factory => :user)
      factory.attributes.should include(attr)
    end

    it "should add an association with a factory name and overrides" do
      factory = Factory.new(:post)
      attr = 'attribute'
      mock(Factory::Attribute::Association).new(:author, :user, :first_name => 'Ben') { attr }
      factory.association(:author, :factory => :user, :first_name => 'Ben')
      factory.attributes.should include(attr)
    end

    it "should raise for a self referencing association" do
      factory = Factory.new(:post)
      lambda {
        factory.association(:parent, :factory => :post)
      }.should raise_error(Factory::AssociationDefinitionError)
    end

    it "should add an attribute using the method name when passed an undefined method" do
      attribute = 'attribute'
      stub(attribute).name { :name }
      block = lambda {}
      mock(Factory::Attribute::Static).new(:name, 'value') { attribute }
      @factory.send(:name, 'value')
      @factory.attributes.should include(attribute)
    end

    it "should allow human_name as a static attribute name" do
      attribute = 'attribute'
      stub(attribute).name { :name }
      mock(Factory::Attribute::Static).new(:human_name, 'value') { attribute}
      @factory.human_name 'value'
    end

    it "should allow human_name as a dynamic attribute name" do
      attribute = 'attribute'
      stub(attribute).name { :name }
      block     = lambda {}
      mock(Factory::Attribute::Dynamic).new(:human_name, block) { attribute }
      @factory.human_name(&block)
    end

    describe "when overriding generated attributes with a hash" do
      before do
        @attr  = :name
        @value = 'The price is right!'
        @hash  = { @attr => @value }
      end

      it "should return the overridden value in the generated attributes" do
        @factory.add_attribute(@attr, 'The price is wrong, Bob!')
        result = @factory.run(Factory::Proxy::AttributesFor, @hash)
        result[@attr].should == @value
      end

      it "should not call a lazy attribute block for an overridden attribute" do
        @factory.add_attribute(@attr) { flunk }
        result = @factory.run(Factory::Proxy::AttributesFor, @hash)
      end

      it "should override a symbol parameter with a string parameter" do
        @factory.add_attribute(@attr, 'The price is wrong, Bob!')
        @hash = { @attr.to_s => @value }
        result = @factory.run(Factory::Proxy::AttributesFor, @hash)
        result[@attr].should == @value
      end
    end

    describe "overriding an attribute with an alias" do
      before do
        @factory.add_attribute(:test, 'original')
        Factory.alias(/(.*)_alias/, '\1')
        @result = @factory.run(Factory::Proxy::AttributesFor,
                               :test_alias => 'new')
      end

      it "should use the passed in value for the alias" do
        @result[:test_alias].should == 'new'
      end

      it "should discard the predefined value for the attribute" do
        @result[:test].should be_nil
      end
    end

    it "should guess the build class from the factory name" do
      @factory.build_class.should == User
    end

    describe "when defined with a custom class" do
      before do
        @class   = User
        @factory = Factory.new(:author, :class => @class)
      end

      it "should use the specified class as the build class" do
        @factory.build_class.should == @class
      end
    end

    describe "when defined with a class instead of a name" do
      before do
        @class   = ArgumentError
        @name    = :argument_error
        @factory = Factory.new(@class)
      end

      it "should guess the name from the class" do
        @factory.factory_name.should == @name
      end

      it "should use the class as the build class" do
        @factory.build_class.should == @class
      end
    end

    describe "when defined with a custom class name" do
      before do
        @class   = ArgumentError
        @factory = Factory.new(:author, :class => :argument_error)
      end

      it "should use the specified class as the build class" do
        @factory.build_class.should == @class
      end
    end
  end

  describe "a factory with a name ending in s" do
    before do
      @name    = :business
      @class   = Business
      @factory = Factory.new(@name)
    end

    it "should have a factory name" do
      @factory.factory_name.should == @name
    end

    it "should have a build class" do
      @factory.build_class.should == @class
    end
  end

  describe "a factory with a string for a name" do
    before do
      @name    = :user
      @factory = Factory.new(@name.to_s) {}
    end

    it "should convert the string to a symbol" do
      @factory.factory_name.should == @name
    end
  end

  describe "a factory defined with a string name" do
    before do
      Factory.factories = {}
      @name    = :user
      @factory = Factory.define(@name.to_s) {}
    end

    it "should store the factory using a symbol" do
      Factory.factories[@name].should == @factory
    end
  end

  describe "a factory for namespaced class" do
    before do
      Factory.factories = {}
      @name  = :settings
      @class = Admin::Settings
    end

    it "should build namespaced class passed by string" do
      factory = Factory.define(@name.to_s, :class => @class.name) {}
      factory.build_class.should == @class
    end

    it "should build Admin::Settings class from Admin::Settings string" do
      factory = Factory.define(@name.to_s, :class => 'admin/settings') {}
      factory.build_class.should == @class
    end
  end

  describe "after defining a factory" do
    before do
      @name    = :user
      @factory = "factory"

      Factory.factories[@name] = @factory
    end

    after { Factory.factories.clear }

    it "should use Proxy::AttributesFor for Factory.attributes_for" do
      mock(@factory).run(Factory::Proxy::AttributesFor, :attr => 'value') { 'result' }
      Factory.attributes_for(@name, :attr => 'value').should == 'result'
    end

    it "should use Proxy::Build for Factory.build" do
      mock(@factory).run(Factory::Proxy::Build, :attr => 'value') { 'result' }
      Factory.build(@name, :attr => 'value').should == 'result'
    end

    it "should use Proxy::Create for Factory.create" do
      mock(@factory).run(Factory::Proxy::Create, :attr => 'value') { 'result' }
      Factory.create(@name, :attr => 'value').should == 'result'
    end

    it "should use Proxy::Stub for Factory.stub" do
      mock(@factory).run(Factory::Proxy::Stub, :attr => 'value') { 'result' }
      Factory.stub(@name, :attr => 'value').should == 'result'
    end

    it "should use default strategy option as Factory.default_strategy" do
      stub(@factory).default_strategy { :create }
      mock(@factory).run(Factory::Proxy::Create, :attr => 'value') { 'result' }
      Factory.default_strategy(@name, :attr => 'value').should == 'result'
    end

    it "should use the default strategy for the global Factory method" do
      stub(@factory).default_strategy { :create }
      mock(@factory).run(Factory::Proxy::Create, :attr => 'value') { 'result' }
      Factory(@name, :attr => 'value').should == 'result'
    end

    [:build, :create, :attributes_for, :stub].each do |method|
      it "should raise an ArgumentError on #{method} with a nonexistant factory" do
        lambda { Factory.send(method, :bogus) }.should raise_error(ArgumentError)
      end

      it "should recognize either 'name' or :name for Factory.#{method}" do
        stub(@factory).run
        lambda { Factory.send(method, @name.to_s) }.should_not raise_error
        lambda { Factory.send(method, @name.to_sym) }.should_not raise_error
      end
    end
  end

  describe 'defining a factory with a parent parameter' do
    before do
      @parent = Factory.define :object do |f|
        f.name  'Name'
      end
    end

    after { Factory.factories.clear }

    it "should raise an ArgumentError when trying to use a non-existent factory as parent" do
      lambda {
        Factory.define(:child, :parent => :nonexsitent) {}
      }.should raise_error(ArgumentError)
    end

    it "should create a new factory using the class of the parent" do
      child = Factory.define(:child, :parent => :object) {}
      child.build_class.should == @parent.build_class
    end

    it "should create a new factory while overriding the parent class" do
      class Other; end

      child = Factory.define(:child, :parent => :object, :class => Other) {}
      child.build_class.should == Other
    end

    it "should create a new factory with attributes of the parent" do
      child = Factory.define(:child, :parent => :object) {}
      child.attributes.size.should == 1
      child.attributes.first.name.should == :name
    end

    it "should allow to define additional attributes" do
      child = Factory.define(:child, :parent => :object) do |f|
        f.email 'person@somebody.com'
      end
      child.attributes.size.should == 2
    end

    it "should allow to override parent attributes" do
      child = Factory.define(:child, :parent => :object) do |f|
        f.name { 'Child Name' }
      end
      child.attributes.size.should == 1
      child.attributes.first.should be_kind_of(Factory::Attribute::Dynamic)
    end

    it "inherit all callbacks" do
      Factory.define(:child, :parent => :object) do |f|
        f.after_stub {|o| o.name = 'Stubby' }
      end

      grandchild = Factory.define(:grandchild, :parent => :child) do |f|
        f.after_stub {|o| o.name = "#{o.name} McStubby" }
      end

      grandchild.attributes.size.should == 3
      grandchild.attributes.first.should be_kind_of(Factory::Attribute::Callback)
      grandchild.attributes[1].should be_kind_of(Factory::Attribute::Callback)
    end
  end

  describe 'defining a factory with a default strategy parameter' do
    it "should raise an ArgumentError when trying to use a non-existent factory" do
      lambda {
        Factory.define(:object, :default_strategy => :nonexistent) {}
      }.should raise_error(ArgumentError)
    end

    it "should create a new factory with a specified default strategy" do
      factory = Factory.define(:object, :default_strategy => :stub) {}
      factory.default_strategy.should == :stub
    end

    describe 'defining a child factory without setting default strategy' do
      before do
        @child = Factory.define(:child_object, :parent => :object) {}
      end

      it "should inherit default strategy from its parent" do
        @child.default_strategy.should == :stub
      end
    end

    describe 'defining a child factory with a default strategy' do
      before do
        @child2 = Factory.define(:child_object2, :parent => :object, :default_strategy => :build) {}
      end

      it "should not inherit default strategy from parent" do
        @child2.default_strategy.should == :build
      end
    end
  end

  def self.in_directory_with_files(*files)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p @tmp_dir
      Dir.chdir(@tmp_dir)

      files.each do |file|
        FileUtils.mkdir_p File.dirname(file)
        FileUtils.touch file
        stub(Factory).require
      end
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end

  def require_definitions_from(file)
    simple_matcher do |given, matcher|
      full_path = File.expand_path(file)
      has_received = have_received.method_missing(:require, full_path)
      result = has_received.matches?(given)
      matcher.description = "require definitions from #{file}"
      matcher.failure_message = has_received.failure_message
      result
    end
  end

  share_examples_for "finds definitions" do
    before do
      stub(Factory).require
      Factory.find_definitions
    end
    subject { Factory }
  end

  describe "with factories.rb" do
    in_directory_with_files 'factories.rb'
    it_should_behave_like "finds definitions"
    it { should require_definitions_from('factories.rb') }
  end

  %w(spec test).each do |dir|
    describe "with a factories file under #{dir}" do
      in_directory_with_files File.join(dir, 'factories.rb')
      it_should_behave_like "finds definitions"
      it { should require_definitions_from("#{dir}/factories.rb") }
    end

    describe "with a factories file under #{dir}/factories" do
      in_directory_with_files File.join(dir, 'factories', 'post_factory.rb')
      it_should_behave_like "finds definitions"
      it { should require_definitions_from("#{dir}/factories/post_factory.rb") }
    end

    describe "with several factories files under #{dir}/factories" do
      in_directory_with_files File.join(dir, 'factories', 'post_factory.rb'),
                              File.join(dir, 'factories', 'person_factory.rb')
      it_should_behave_like "finds definitions"
      it { should require_definitions_from("#{dir}/factories/post_factory.rb") }
      it { should require_definitions_from("#{dir}/factories/person_factory.rb") }
    end

    describe "with nested and unnested factories files under #{dir}" do
      in_directory_with_files File.join(dir, 'factories.rb'),
                              File.join(dir, 'factories', 'post_factory.rb'),
                              File.join(dir, 'factories', 'person_factory.rb')
      it_should_behave_like "finds definitions"
      it { should require_definitions_from("#{dir}/factories.rb") }
      it { should require_definitions_from("#{dir}/factories/post_factory.rb") }
      it { should require_definitions_from("#{dir}/factories/person_factory.rb") }
    end
  end

  it "should return the factory name without underscores for the human name" do
    factory = Factory.new(:name_with_underscores)
    factory.human_name.should == 'name with underscores'
  end

end

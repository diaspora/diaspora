require 'spec_helper'

describe FactoryGirl::Factory do
  include DefinesConstants

  before do
    @name    = :user
    @class   = define_class('User')
    @factory = FactoryGirl::Factory.new(@name)
  end

  it "should have a factory name" do
    @factory.name.should == @name
  end

  it "responds to factory_name" do
    @factory.factory_name.should == @name
  end

  it "should have a build class" do
    @factory.build_class.should == @class
  end

  it "should have a default strategy" do
    @factory.default_strategy.should == :create
  end

  it "should not allow the same attribute to be added twice" do
    lambda {
      2.times { @factory.define_attribute FactoryGirl::Attribute::Static.new(:name, 'value') }
    }.should raise_error(FactoryGirl::AttributeDefinitionError)
  end

  it "should add a callback attribute when defining a callback" do
    mock(FactoryGirl::Attribute::Callback).new(:after_create, is_a(Proc)) { 'after_create callback' }
    @factory.add_callback(:after_create) {}
    @factory.attributes.should include('after_create callback')
  end

  it "should raise an InvalidCallbackNameError when defining a callback with an invalid name" do
    lambda{
      @factory.add_callback(:invalid_callback_name) {}
    }.should raise_error(FactoryGirl::InvalidCallbackNameError)
  end

  describe "after adding an attribute" do
    before do
      @attribute = "attribute"
      @proxy     = "proxy"

      stub(@attribute).name { :name }
      stub(@attribute).add_to
      stub(@proxy).set
      stub(@proxy).result { 'result' }
      stub(FactoryGirl::Attribute::Static).new { @attribute }
      stub(FactoryGirl::Proxy::Build).new { @proxy }

      @factory.define_attribute(@attribute)
    end

    it "should create the right proxy using the build class when running" do
      mock(FactoryGirl::Proxy::Build).new(@factory.build_class) { @proxy }
      @factory.run(FactoryGirl::Proxy::Build, {})
    end

    it "should add the attribute to the proxy when running" do
      mock(@attribute).add_to(@proxy)
      @factory.run(FactoryGirl::Proxy::Build, {})
    end

    it "should return the result from the proxy when running" do
      mock(@proxy).result(nil) { 'result' }
      @factory.run(FactoryGirl::Proxy::Build, {}).should == 'result'
    end
  end

  it "passes a custom creation block" do
    proxy = 'proxy'
    stub(FactoryGirl::Proxy::Build).new { proxy }
    stub(proxy).result {}
    block = lambda {}
    factory = FactoryGirl::Factory.new(:object)
    factory.to_create(&block)

    factory.run(FactoryGirl::Proxy::Build, {})

    proxy.should have_received.result(block)
  end

  it "should return associations" do
    factory = FactoryGirl::Factory.new(:post)
    FactoryGirl.register_factory(FactoryGirl::Factory.new(:admin))
    factory.define_attribute(FactoryGirl::Attribute::Association.new(:author, :author, {}))
    factory.define_attribute(FactoryGirl::Attribute::Association.new(:editor, :editor, {}))
    factory.define_attribute(FactoryGirl::Attribute::Implicit.new(:admin))
    factory.associations.each do |association|
      association.should be_association
    end
    factory.associations.size.should == 3
  end

  it "should raise for a self referencing association" do
    factory = FactoryGirl::Factory.new(:post)
    lambda {
      factory.define_attribute(FactoryGirl::Attribute::Association.new(:parent, :post, {}))
    }.should raise_error(FactoryGirl::AssociationDefinitionError)
  end

  describe "when overriding generated attributes with a hash" do
    before do
      @name  = :name
      @value = 'The price is right!'
      @hash  = { @name => @value }
    end

    it "should return the overridden value in the generated attributes" do
      attr = FactoryGirl::Attribute::Static.new(@name, 'The price is wrong, Bob!')
      @factory.define_attribute(attr)
      result = @factory.run(FactoryGirl::Proxy::AttributesFor, @hash)
      result[@name].should == @value
    end

    it "should not call a lazy attribute block for an overridden attribute" do
      attr = FactoryGirl::Attribute::Dynamic.new(@name, lambda { flunk })
      @factory.define_attribute(attr)
      result = @factory.run(FactoryGirl::Proxy::AttributesFor, @hash)
    end

    it "should override a symbol parameter with a string parameter" do
      attr = FactoryGirl::Attribute::Static.new(@name, 'The price is wrong, Bob!')
      @factory.define_attribute(attr)
      @hash = { @name.to_s => @value }
      result = @factory.run(FactoryGirl::Proxy::AttributesFor, @hash)
      result[@name].should == @value
    end
  end

  describe "overriding an attribute with an alias" do
    before do
      @factory.define_attribute(FactoryGirl::Attribute::Static.new(:test, 'original'))
      Factory.alias(/(.*)_alias/, '\1')
      @result = @factory.run(FactoryGirl::Proxy::AttributesFor,
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

  it "should create a new factory using the class of the parent" do
    child = FactoryGirl::Factory.new(:child)
    child.inherit_from(@factory)
    child.build_class.should == @factory.build_class
  end

  it "should create a new factory while overriding the parent class" do
    child = FactoryGirl::Factory.new(:child, :class => String)
    child.inherit_from(@factory)
    child.build_class.should == String
  end

  describe "given a parent with attributes" do
    before do
      @parent_attr = :name
      @factory.define_attribute(FactoryGirl::Attribute::Static.new(@parent_attr, 'value'))
    end

    it "should create a new factory with attributes of the parent" do
      child = FactoryGirl::Factory.new(:child)
      child.inherit_from(@factory)
      child.attributes.size.should == 1
      child.attributes.first.name.should == @parent_attr
    end

    it "should allow a child to define additional attributes" do
      child = FactoryGirl::Factory.new(:child)
      child.define_attribute(FactoryGirl::Attribute::Static.new(:email, 'value'))
      child.inherit_from(@factory)
      child.attributes.size.should == 2
    end

    it "should allow to override parent attributes" do
      child = FactoryGirl::Factory.new(:child)
      @child_attr = FactoryGirl::Attribute::Static.new(@parent_attr, 'value')
      child.define_attribute(@child_attr)
      child.inherit_from(@factory)
      child.attributes.size.should == 1
      child.attributes.first.should == @child_attr
    end

    it "should allow to use parent attributes in defining additional attributes" do
      User.class_eval { attr_accessor :name, :email }

      child = FactoryGirl::Factory.new(:child)
      @child_attr = FactoryGirl::Attribute::Dynamic.new(:email, lambda {|u| "#{u.name}@example.com"})
      child.define_attribute(@child_attr)
      child.inherit_from(@factory)
      child.attributes.size.should == 2

      result = child.run(FactoryGirl::Proxy::Build, {})
      result.email.should == 'value@example.com'
    end
  end

  it "inherit all callbacks" do
    @factory.add_callback(:after_stub) { |object| object.name = 'Stubby' }
    child = FactoryGirl::Factory.new(:child)
    child.inherit_from(@factory)
    child.attributes.last.should be_kind_of(FactoryGirl::Attribute::Callback)
  end
end

describe FactoryGirl::Factory, "when defined with a custom class" do
  before do
    @class   = Float
    @factory = FactoryGirl::Factory.new(:author, :class => @class)
  end

  it "should use the specified class as the build class" do
    @factory.build_class.should == @class
  end
end

describe FactoryGirl::Factory, "when defined with a class instead of a name" do
  before do
    @class   = ArgumentError
    @name    = :argument_error
    @factory = FactoryGirl::Factory.new(@class)
  end

  it "should guess the name from the class" do
    @factory.name.should == @name
  end

  it "should use the class as the build class" do
    @factory.build_class.should == @class
  end
end

describe FactoryGirl::Factory, "when defined with a custom class name" do
  before do
    @class   = ArgumentError
    @factory = FactoryGirl::Factory.new(:author, :class => :argument_error)
  end

  it "should use the specified class as the build class" do
    @factory.build_class.should == @class
  end
end

describe FactoryGirl::Factory, "with a name ending in s" do
  include DefinesConstants

  before do
    define_class('Business')
    @name    = :business
    @class   = Business
    @factory = FactoryGirl::Factory.new(@name)
  end

  it "should have a factory name" do
    @factory.name.should == @name
  end

  it "should have a build class" do
    @factory.build_class.should == @class
  end
end

describe FactoryGirl::Factory, "with a string for a name" do
  before do
    @name    = :string
    @factory = FactoryGirl::Factory.new(@name.to_s) {}
  end

  it "should convert the string to a symbol" do
    @factory.name.should == @name
  end
end

describe FactoryGirl::Factory, "for namespaced class" do
  include DefinesConstants

  before do
    define_class('Admin')
    define_class('Admin::Settings')

    @name  = :settings
    @class = Admin::Settings
  end

  it "should build namespaced class passed by string" do
    factory = FactoryGirl::Factory.new(@name.to_s, :class => @class.name)
    factory.build_class.should == @class
  end

  it "should build Admin::Settings class from Admin::Settings string" do
    factory = FactoryGirl::Factory.new(@name.to_s, :class => 'admin/settings')
    factory.build_class.should == @class
  end
end

describe FactoryGirl::Factory do
  include DefinesConstants

  before do
    define_class('User')
    define_class('Admin', User)
  end

  it "should raise an ArgumentError when trying to use a non-existent strategy" do
    lambda {
      FactoryGirl::Factory.new(:object, :default_strategy => :nonexistent) {}
    }.should raise_error(ArgumentError)
  end

  it "should create a new factory with a specified default strategy" do
    factory = FactoryGirl::Factory.new(:object, :default_strategy => :stub)
    factory.default_strategy.should == :stub
  end

  describe 'defining a child factory without setting default strategy' do
    before do
      @parent = FactoryGirl::Factory.new(:object, :default_strategy => :stub)
      @child = FactoryGirl::Factory.new(:child_object)
      @child.inherit_from(@parent)
    end

    it "should inherit default strategy from its parent" do
      @child.default_strategy.should == :stub
    end
  end

  describe 'defining a child factory with a default strategy' do
    before do
      @parent = FactoryGirl::Factory.new(:object, :default_strategy => :stub)
      @child = FactoryGirl::Factory.new(:child_object2, :default_strategy => :build)
      @child.inherit_from(@parent)
    end

    it "should override the default strategy from parent" do
      @child.default_strategy.should == :build
    end
  end

end

describe FactoryGirl::Factory, "human names" do
  context "factory name without underscores" do
    subject           { FactoryGirl::Factory.new("user") }
    its(:human_names) { should == ["user"] }
  end

  context "factory name with underscores" do
    subject           { FactoryGirl::Factory.new("happy_user") }
    its(:human_names) { should == ["happy user"] }
  end

  context "factory name with aliases" do
    subject           { FactoryGirl::Factory.new("happy_user", :aliases => ["gleeful_user", "person"]) }
    its(:human_names) { should == ["happy user", "gleeful user", "person"] }
  end
end

describe FactoryGirl::Factory, "with aliases" do
  it "registers the aliases" do
    name = :user
    aliased_name = :guest
    factory = FactoryGirl::Factory.new(:user, :aliases => [aliased_name])
    factory.names.should =~ [name, aliased_name]
  end

  it "has human names" do
    name = :user
    aliased_name = :guest
    factory = FactoryGirl::Factory.new(:user, :aliases => [aliased_name])
    factory.human_names.should =~ [name.to_s, aliased_name.to_s]
  end
end

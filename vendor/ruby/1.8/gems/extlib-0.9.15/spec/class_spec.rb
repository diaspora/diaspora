require 'spec_helper'
require 'extlib/class'

class Grandparent
end

class Parent < Grandparent
end

class Child < Parent
end

class Parent
end

class Grandparent
  class_inheritable_accessor :last_name, :_attribute

  self._attribute = 1900
end

class ClassWithInheritableSymbolAccessor
  class_inheritable_accessor :symbol
  self.symbol = :foo
end

class ClassInheritingSymbolAccessor < ClassWithInheritableSymbolAccessor
end

describe Class, "#inheritable_accessor" do

  after :each do
    Grandparent.send(:remove_instance_variable, "@last_name") rescue nil
    Parent.send(:remove_instance_variable, "@last_name") rescue nil
    Child.send(:remove_instance_variable, "@last_name") rescue nil
  end

  it 'inherits from parent unless overriden' do
    Parent._attribute.should == 1900
    Child._attribute.should == 1900
  end

  it 'inherits from grandparent unless overriden' do
    Child._attribute.should == 1900
  end

  it "inherits even if the accessor is made after the inheritance" do
    Grandparent.last_name = "Merb"
    Parent.last_name.should == "Merb"
    Child.last_name.should == "Merb"
  end

  it "supports ||= to change a child" do
    Parent.last_name ||= "Merb"
    Grandparent.last_name.should == nil
    Parent.last_name.should == "Merb"
    Child.last_name.should == "Merb"
  end

  it "supports << to change a child when the parent is an Array" do
    Grandparent.last_name = ["Merb"]
    Parent.last_name << "Core"
    Grandparent.last_name.should == ["Merb"]
    Parent.last_name.should == ["Merb", "Core"]
  end

  it "supports ! methods on an Array" do
    Grandparent.last_name = %w(Merb Core)
    Parent.last_name.reverse!
    Grandparent.last_name.should == %w(Merb Core)
    Parent.last_name.should == %w(Core Merb)
  end

  it "support modifying a parent Hash" do
    Grandparent.last_name = {"Merb" => "name"}
    Parent.last_name["Core"] = "name"
    Parent.last_name.should == {"Merb" => "name", "Core" => "name"}
    Grandparent.last_name.should == {"Merb" => "name"}
  end

  it "supports hard-merging a parent Hash" do
    Grandparent.last_name = {"Merb" => "name"}
    Parent.last_name.merge!("Core" => "name")
    Parent.last_name.should == {"Merb" => "name", "Core" => "name"}
    Grandparent.last_name.should == {"Merb" => "name"}
  end

  it "supports changes to the parent even if the child has already been read" do
    Child.last_name
    Grandparent.last_name = "Merb"
    Child.last_name.should == "Merb"
  end

  it "handles nil being set midstream" do
    Child.last_name
    Parent.last_name = nil
    Grandparent.last_name = "Merb"
    Child.last_name.should == nil
  end

  it "handles false being used in Parent" do
    Child.last_name
    Parent.last_name = false
    Grandparent.last_name = "Merb"
    Child.last_name.should == false
  end

  it "handles the grandparent changing the value (as long as the child isn't read first)" do
    Grandparent.last_name = "Merb"
    Grandparent.last_name = "Core"
    Child.last_name.should == "Core"
  end

end

describe Class, "#inheritable_accessor (of type Symbol)" do

  it "should not raise" do
    lambda { ClassInheritingSymbolAccessor.symbol }.should_not raise_error(TypeError)
  end

end

#
# The bug that prompted this estoric spec was found in
# the wild when using dm-is-versioned with c_i_w.
#

module Plugin
  def self.included(base)
    base.class_eval do
      class_inheritable_writer :plugin_options
      class_inheritable_reader :plugin_options
      self.plugin_options = :foo
    end
  end
end

class Model
  def self.new
    model = Class.new
    model.send(:include, Plugin)
    model
  end

  include Plugin
  self.const_set("Version", Model.new)
end

describe Class, "#inheritable_accessor" do
  it "uses object_id for comparison" do
    Model.methods.map { |m| m.to_sym }.should be_include(:plugin_options)
    Model.plugin_options.should == :foo

    Model::Version.methods.map { |m| m.to_sym }.should be_include(:plugin_options)
    Model::Version.plugin_options.should == :foo
  end
end

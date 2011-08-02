require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::ModuleObject do
  describe "#meths" do
    before do 
      Registry.clear 
    
      # setup the object space:
      # 
      #   YARD:module
      #   YARD#foo:method
      #   YARD#foo2:method
      #   YARD#xyz:method
      #   YARD.bar:method
      #   SomeMod#mixmethod
      #   SomeMod#xyz:method
      # 
      @yard = ModuleObject.new(:root, :YARD)
      MethodObject.new(@yard, :foo)
      MethodObject.new(@yard, :xyz)
      MethodObject.new(@yard, :foo2) do |o|
        o.visibility = :protected
      end
      MethodObject.new(@yard, :bar, :class) do |o|
        o.visibility = :private
      end
      @other = ModuleObject.new(:root, :SomeMod)
      MethodObject.new(@other, :mixmethod)
      MethodObject.new(@other, :xyz)
      MethodObject.new(@other, :baz, :class)
      @another = ModuleObject.new(:root, :AnotherMod)
      MethodObject.new(@another, :fizz)
      MethodObject.new(@another, :bar)
      MethodObject.new(@another, :fazz, :class)
    
      @yard.instance_mixins << @other
      @yard.class_mixins << @another
    end
  
    it "should list all methods (including mixin methods) via #meths" do
      meths = @yard.meths
      meths.should include(P("YARD#foo"))
      meths.should include(P("YARD#foo2"))
      meths.should include(P("YARD.bar"))
      meths.should include(P("SomeMod#mixmethod"))
      meths.should include(P("AnotherMod#fizz"))
    end
  
    it "should allow :visibility to be set" do
      meths = @yard.meths(:visibility => :public)
      meths.should_not include(P("YARD.bar"))
      meths = @yard.meths(:visibility => [:public, :private])
      meths.should include(P("YARD#foo"))
      meths.should include(P("YARD.bar"))
      meths.should_not include(P("YARD#foo2"))
    end
  
    it "should only display class methods for :scope => :class" do
      meths = @yard.meths(:scope => :class)
      meths.should_not include(P("YARD#foo"))
      meths.should_not include(P("YARD#foo2"))
      meths.should_not include(P("SomeMod#mixmethod"))
      meths.should_not include(P("SomeMod.baz"))
      meths.should_not include(P("AnotherMod#fazz"))
      meths.should include(P("YARD.bar"))
      meths.should include(P("AnotherMod#fizz"))
    end
  
    it "should only display instance methods for :scope => :class" do
      meths = @yard.meths(:scope => :instance)
      meths.should include(P("YARD#foo"))
      meths.should include(P("YARD#foo2"))
      meths.should include(P("SomeMod#mixmethod"))
      meths.should_not include(P("YARD.bar"))
      meths.should_not include(P("AnotherMod#fizz"))
    end
  
    it "should allow :included to be set" do
      meths = @yard.meths(:included => false)
      meths.should_not include(P("SomeMod#mixmethod"))
      meths.should_not include(P("AnotherMod#fizz"))
      meths.should include(P("YARD#foo"))
      meths.should include(P("YARD#foo2"))
      meths.should include(P("YARD.bar"))
    end
  
    it "should choose the method defined in the class over an included module" do
      meths = @yard.meths
      meths.should_not include(P("SomeMod#xyz"))
      meths.should include(P("YARD#xyz"))
      meths.should_not include(P("AnotherMod#bar"))
      meths.should include(P("YARD.bar"))
    
      meths = @other.meths
      meths.should include(P("SomeMod#xyz"))

      meths = @another.meths
      meths.should include(P("AnotherMod#bar"))
    end
  end

  describe "#inheritance_tree" do
    before do
      Registry.clear

      @mod1 = ModuleObject.new(:root, :Mod1)
      @mod2 = ModuleObject.new(:root, :Mod2)
      @mod3 = ModuleObject.new(:root, :Mod3)
      @mod4 = ModuleObject.new(:root, :Mod4)
      @mod5 = ModuleObject.new(:root, :Mod5)

      @mod1.instance_mixins << @mod2
      @mod2.instance_mixins << @mod3
      @mod3.instance_mixins << @mod4
      @mod1.instance_mixins << @mod4
    
      @proxy = P(:SomeProxyClass)
      @mod5.instance_mixins << @proxy
    end

    it "should show only itself for an inheritance tree without included modules" do
      @mod1.inheritance_tree.should == [@mod1]
    end

    it "should show proper inheritance three when modules are included" do
      @mod1.inheritance_tree(true).should == [@mod1, @mod2, @mod3, @mod4]
    end
  
    it "should not list inheritance tree of proxy objects in inheritance tree" do
      @proxy.should_not_receive(:inheritance_tree)
      @mod5.instance_mixins.should == [@proxy]
    end
    
    it "should list class mixins in inheritance tree" do
      mod = ModuleObject.new(:root, :ClassMethods)
      recvmod = ModuleObject.new(:root, :ReceivingModule)
      recvmod.class_mixins << mod
      recvmod.inheritance_tree(true).should == [recvmod, mod]
    end
  end
end
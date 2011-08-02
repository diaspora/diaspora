require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Section do
  include YARD::Templates
  
  describe '#initialize' do
    it "should convert first argument to splat if it is array" do
      s = Section.new(:name, [:foo, :bar])
      s.name.should == :name
      s[0].name.should == :foo
      s[1].name.should == :bar
    end
    
    it "should allow initialization with Section objects" do
      s = Section.new(:name, [:foo, Section.new(:bar)])
      s.name.should == :name
      s[0].should == Section.new(:foo)
      s[1].should == Section.new(:bar)
    end

    it "should make a list of sections" do
      s = Section.new(:name, [:foo, [:bar]])
      s.should == Section.new(:name, Section.new(:foo, Section.new(:bar)))
    end
  end
  
  describe '#[]' do
    it "should use Array#[] if argument is integer" do
      Section.new(:name, [:foo, :bar])[0].name.should == :foo
    end
    
    it "should return new Section object if more than one argument" do
      Section.new(:name, :foo, :bar, :baz)[1, 2].should ==
        Section.new(:name, :bar, :baz)
    end
    
    it "should return new Section object if arg is Range" do
      Section.new(:name, :foo, :bar, :baz)[1..2].should ==
        Section.new(:name, :bar, :baz)
    end
    
    it "should look for section by name if arg is object" do
      Section.new(:name, :foo, :bar, [:baz])[:bar][:baz].should ==
        Section.new(:baz)
    end
  end
  
  describe '#eql?' do
    it "should check for equality of two equal sections" do
      Section.new(:foo, [:a, :b]).should be_eql(Section.new(:foo, :a, :b))
      Section.new(:foo, [:a, :b]).should == Section.new(:foo, :a, :b)
    end
    
    it "should not be equal if section names are different" do
      Section.new(:foo, [:a, :b]).should_not be_eql(Section.new(:bar, :a, :b))
      Section.new(:foo, [:a, :b]).should_not == Section.new(:bar, :a, :b)
    end
  end
  
  describe '#==' do
    it "should allow comparison to Symbol" do
      Section.new(:foo, 2, 3).should == :foo
    end
    
    it "should allow comparison to String" do
      Section.new("foo", 2, 3).should == "foo"
    end
    
    it "should allow comparison to Template" do
      t = YARD::Templates::Engine.template!(:xyzzy, '/full/path/xyzzy')
      Section.new(t, 2, 3).should == t
    end
    
    it "should allow comparison to Section" do
      Section.new(1, [2, 3]).should == Section.new(1, 2, 3)
    end
    
    it "should allow comparison to Object" do
      Section.new(1, [2, 3]).should == 1
    end
    
    it "should allow comparison to Array" do
      Section.new(1, 2, [3]).should == [1, [2, [3]]]
    end
  end
  
  describe '#to_a' do
    it "should convert Section to regular Array list" do
      arr = Section.new(1, 2, [3, [4]]).to_a
      arr.class.should == Array
      arr.should == [1, [2, [3, [4]]]]
    end
  end
  
  describe '#place' do
    it "should place objects as Sections" do
      Section.new(1, 2, 3).place(4).before(3).should == [1, [2, 4, 3]]
    end
    
    it "should place objects anywhere inside Section with before/after_any" do
      Section.new(1, 2, [3, [4]]).place(5).after_any(4).should == [1, [2, [3, [4, 5]]]]
      Section.new(1, 2, [3, [4]]).place(5).before_any(4).should == [1, [2, [3, [5, 4]]]]
    end
    
    it "should allow multiple sections to be placed" do
      Section.new(1, 2, 3).place(4, 5).after(3).to_a.should == [1, [2, 3, 4, 5]]
      Section.new(1, 2, 3).place(4, [5]).after(3).to_a.should == [1, [2, 3, 4, [5]]]
    end
  end
  
  describe '#push' do
    it "should push objects as Sections" do
      s = Section.new(:foo)
      s.push :bar
      s[0].should == Section.new(:bar)
    end
    
    it "should alias to #<<" do
      s = Section.new(1)
      s << :index
      s[:index].should be_a(Section)
    end
  end
  
  describe '#unshift' do
    it "should unshift objects as Sections" do
      s = Section.new(:foo)
      s.unshift :bar
      s[0].should == Section.new(:bar)
    end
  end
  
  describe '#any' do
    it "should find item inside sections" do
      s = Section.new(:foo, Section.new(:bar, Section.new(:bar)))
      s.any(:bar).push(:baz)
      s.to_a.should == [:foo, [:bar, [:bar, :baz]]]
    end
    
    it "should find item in any deeply nested set of sections" do
      s = Section.new(:foo, Section.new(:bar, Section.new(:baz)))
      s.any(:baz).push(:qux)
      s.to_a.should == [:foo, [:bar, [:baz, [:qux]]]]
    end
  end
end
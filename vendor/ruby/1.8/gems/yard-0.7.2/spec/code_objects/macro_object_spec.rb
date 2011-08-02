require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::MacroObject do
  before do 
    Registry.clear 
  end
  
  describe '.create' do
    def create(*args) MacroObject.create(*args) end

    it "should create an object" do
      create('foo', '')
      obj = Registry.at('.macro.foo')
      obj.should_not be_nil
    end
    
    it "should use identity map" do
      obj1 = create('foo', '')
      obj2 = create('foo', '')
      obj1.object_id.should == obj2.object_id
    end
    
    it "should allow specifying of macro data" do
      obj = create('foo', 'MACRODATA')
      obj.macro_data.should == 'MACRODATA'
    end
    
    it "should attach if a method object is provided" do
      obj = create('foo', 'MACRODATA', P('Foo.property'))
      obj.method_object.should == P('Foo.property')
      obj.should be_attached
    end
  end
  
  describe '.find' do
    before { MacroObject.create('foo', 'DATA') }
    
    it "should search for an object by name" do
      MacroObject.find('foo').macro_data.should == 'DATA'
    end
    
    it "should accept Symbol" do
      MacroObject.find(:foo).macro_data.should == 'DATA'
    end
  end
  
  describe '.find_or_create' do
    it "should look up name if @macro is present and find object" do
      macro1 = MacroObject.create('foo', 'FOO')
      macro2 = MacroObject.find_or_create("@macro foo\na b c")
      macro1.should == macro2
    end
    
    it "should create new macro if macro by that name does not exist" do
      MacroObject.find_or_create("@macro foo\n  @method $1\nEXTRA")
      MacroObject.find('foo').macro_data.should == "@method $1"
    end
    
    it "should use full docstring if no text block is present in @macro" do
      MacroObject.find_or_create("@macro foo\n@method $1\nEXTRA")
      MacroObject.find('foo').macro_data.should == "EXTRA\n@method $1"
    end
  end
  
  describe '.apply' do
    before do
      @args = %w(foo a b c)
    end
    
    def apply(comments)
      MacroObject.apply(comments, @args)
    end

    it "should only expand macros if @macro is present" do
      apply("$1$2$3").should == "$1$2$3"
    end

    it "should handle macro text inside block" do
      apply("@macro name\n  foo$1$2$3\nfoobaz").should == "fooabc\nfoobaz"
    end
    
    it "should append docstring to existing macro" do
      macro = MacroObject.create('name', '$3$2$1')
      result = MacroObject.apply("@macro name\nfoobar", @args)
      result.should == "cba\nfoobar"
    end
    
    it "should use only non macro data if docstring is an existing macro" do
      data = "@macro name\n  $3$2$1\nEXTRA"
      MacroObject.find_or_create(data)
      result = MacroObject.apply(data, @args)
      result.should == "cba\nEXTRA"
      MacroObject.apply("@macro name\nFOO", @args).should == "cba\nFOO"
    end
    
    it "should create macros if they don't exist" do
      result = MacroObject.apply("@macro name\n  foo!$1", @args)
      result.should == "foo!a"
      MacroObject.find('name').macro_data.should == 'foo!$1'
    end
    
    it "should keep other tags" do
      apply("@macro name\n  foo$1$2$3\n@param name foo\nfoo").should == 
        "fooabc\nfoo\n@param name\n  foo"
    end
  end

  describe '.expand' do
    def expand(comments)
      args = %w(foo a b c)
      full_line = 'foo :bar, :baz'
      MacroObject.expand(comments, args, full_line)
    end

    it "should allow escaping of macro syntax" do
      expand("$1\\$2$3").should == "a$2c"
    end

    it "should replace $* with the whole statement" do
      expand("$* ${*}").should == "foo :bar, :baz foo :bar, :baz"
    end

    it "should replace $0 with method name" do
      expand("$0 ${0}").should == "foo foo"
    end

    it "should replace all $N values with the Nth argument in the method call" do
      expand("$1$2$3${3}\nfoobar").should == "abcc\nfoobar"
    end

    it "should replace ${N-M} ranges with N-M arguments (incl. commas)" do
      expand("${1-2}x").should == "a, bx"
    end

    it "should handle open ended ranges (${N-})" do
      expand("${2-}").should == "b, c"
    end

    it "should handle negative indexes ($-N)" do
      expand("$-1 ${-2-} ${-2--2}").should == "c b, c b"
    end
    
    it "should accept Docstring objects" do
      expand(Docstring.new("$1\n@param name foo")).should == "a\n@param name foo"
    end
  end
  
  describe '#expand' do
    it "should expand macro given its data" do
      macro = MacroObject.create_docstring("@macro foo\n  $1 $2 THREE!")
      macro.expand(['NAME', 'ONE', 'TWO']).should == "ONE TWO THREE!"
    end
  end
end

require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Engine.template(:default, :module) do
  before do 
    Registry.clear
    YARD.parse_string <<-'eof'
      module B
        def c; end
        def d; end
        private
        def e; end
      end

      module BaseMod
        attr_reader :base_attr1
        attr_writer :base_attr2
        attr_accessor :base_attr3
      end

      # Comments
      module A
        include BaseMod
        attr_accessor :attr1
        attr_reader :attr2
        
        # @overload attr3
        #   @return [String] a string
        # @overload attr3=(value)
        #   @param [String] value sets the string
        #   @return [void]
        attr_accessor :attr3
        
        attr_writer :attr4
        
        def self.a; end
        def a; end
        alias b a

        # @overload test_overload(a)
        #   hello2
        #   @param [String] a hi
        def test_overload(*args) end
          
        # @overload test_multi_overload(a)
        # @overload test_multi_overload(a, b)
        def test_multi_overload(*args) end
          
        # @return [void]
        def void_meth; end
        
        include B
        
        class Y; end
        class Q; end
        class X; end
        module Z; end
        # A long docstring for the constant. With extra text
        # and newlines.
        CONSTANT = 'value'
        @@cvar = 'value' # @deprecated
      end
      
      module TMP; include A end
      class TMP2; extend A end
    eof
  end

  it "should render html format correctly" do
    html_equals(Registry.at('A').format(
          :format => :html, :no_highlight => true, :hide_void_return => true,
          :verifier => Verifier.new('object.type != :method || object.visibility == :public')),
        :module001)
  end

  it "should render text format correctly" do
    YARD.parse_string <<-'eof'
      module A
        include D, E, F, A::B::C
      end
    eof

    text_equals(Registry.at('A').format, :module001)
  end
  
  it "should render dot format correctly" do
    Registry.at('A').format(:format => :dot, :dependencies => true, :full => true).should == example_contents(:module001, 'dot')
  end
  
  it "should render groups correctly in html" do
    Registry.clear
    YARD.parse_string <<-'eof'
      module A
        # @group Foo
        attr_accessor :foo_attr
        def foo; end
        def self.bar; end
        
        # @group Bar
        def baz; end
        
        # @endgroup
         
        def self.baz; end
      end
    eof
    
    html_equals(Registry.at('A').format(:format => :html, :no_highlight => true), :module002)
  end
end

shared_examples_for "signature" do
  before do
    YARD::Registry.clear 
    stub!(:options).and_return(:default_return => "Object")
  end

  it "should show signature for regular instance method" do
    YARD.parse_string "def foo; end"
    signature(Registry.at('#foo')).should == @results[:regular]
  end

  it "should allow default return type to be changed" do
    stub!(:options).and_return(:default_return => "Hello")
    YARD.parse_string "def foo; end"
    signature(Registry.at('#foo')).should == @results[:default_return]
  end

  it "should allow default return type to be omitted" do
    stub!(:options).and_return(:default_return => "")
    YARD.parse_string "def foo; end"
    signature(Registry.at('#foo')).should == @results[:no_default_return]
  end

  it "should show signature for private class method" do
    YARD.parse_string "class A; private; def self.foo; end end"
    signature(Registry.at('A.foo')).should == @results[:private_class]
  end

  it "should show return type for single type" do
    YARD.parse_string <<-'eof'
      # @return [String]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:single]
  end

  it "should show return type for 2 types" do
    YARD.parse_string <<-'eof'
      # @return [String, Symbol]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:two_types]
  end

  it "should show return type for 2 types over multiple tags" do
    YARD.parse_string <<-'eof'
      # @return [String]
      # @return [Symbol]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:two_types_multitag]
  end

  it "should show 'Type?' if return types are [Type, nil]" do
    YARD.parse_string <<-'eof'
      # @return [Type, nil]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:type_nil]
  end
  
  it "should show 'Type?' if return types are [Type, nil, nil] (extra nil)" do
    YARD.parse_string <<-'eof'
      # @return [Type, nil]
      # @return [nil]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:type_nil]
  end

  it "should show 'Type+' if return types are [Type, Array<Type>]" do
    YARD.parse_string <<-'eof'
      # @return [Type, <Type>]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:type_array]
  end

  it "should (Type, ...) for more than 2 return types" do
    YARD.parse_string <<-'eof'
      # @return [Type, <Type>]
      # @return [AnotherType]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:multitype]
  end

  it "should show (void) for @return [void] by default" do
    YARD.parse_string <<-'eof'
      # @return [void]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:void]
  end

  it "should not show return for @return [void] if :hide_void_return is true" do
    stub!(:options).and_return(:hide_void_return => true)
    YARD.parse_string <<-'eof'
      # @return [void]
      def foo; end
    eof
    signature(Registry.at('#foo')).should == @results[:hide_void]
  end

  it "should show block for method with yield" do
    YARD.parse_string <<-'eof'
      def foo; yield(a, b, c) end
    eof
    signature(Registry.at('#foo')).should == @results[:block]
  end
  
  it "should use regular return tag if the @overload is empty" do
    YARD.parse_string <<-'eof'
      # @overload foobar
      #   Hello world
      # @return [String]
      def foo; end
    eof
    signature(Registry.at('#foo').tag(:overload)).should == @results[:empty_overload]
  end
end

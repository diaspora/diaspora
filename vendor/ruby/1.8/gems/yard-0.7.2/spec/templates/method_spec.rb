require File.dirname(__FILE__) + '/spec_helper'

# $COPY = :method001
# $COPYT = :html

describe YARD::Templates::Engine.template(:default, :method) do
  before { Registry.clear }
  
  shared_examples_for "all formats" do
    it "should render html format correctly" do
      html_equals(Registry.at('#m').format(:format => :html, :no_highlight => true), @template)
    end
    
    it "should render text format correctly" do
      text_equals(Registry.at('#m').format, @template)
    end
  end
  
  describe 'regular (deprecated) method' do
    before do
      @template = :method001
      YARD.parse_string <<-'eof'
        private
        # Comments
        # @param [Hash] x the x argument
        # @option x [String] :key1 (default) first key
        # @option x [Symbol] :key2 second key
        # @return [String] the result
        # @raise [Exception] hi!
        # @deprecated for great justice
        def m(x) end
        alias x m
      eof
    end
    
    it_should_behave_like "all formats"
  end
  
  describe 'method with 1 overload' do
    before do
      @template = :method002
      YARD.parse_string <<-'eof'
        private
        # Comments
        # @overload m(x, y)
        #   @param [String] x parameter x
        #   @param [Boolean] y parameter y
        def m(x) end
      eof
    end
    
    it_should_behave_like "all formats"
  end
  
  describe 'method with 2 overloads' do
    before do
      @template = :method003
      YARD.parse_string <<-'eof'
        private
        # Method comments
        # @overload m(x, y)
        #   Overload docstring
        #   @param [String] x parameter x
        #   @param [Boolean] y parameter y
        # @overload m(x, y, z)
        #   @param [String] x parameter x
        #   @param [Boolean] y parameter y
        #   @param [Boolean] z parameter z
        def m(*args) end
      eof
    end
    
    it_should_behave_like "all formats"
  end
  
  describe 'method void return' do
    before do
      @template = :method004
      YARD.parse_string <<-'eof'
        # @return [void]
        def m(*args) end
      eof
    end

    it_should_behave_like "all formats"
  end
  
  describe 'method void return in an overload' do
    before do
      @template = :method005
      YARD.parse_string <<-'eof'
        # @overload m(a)
        #   @return [void]
        # @overload m(b)
        #   @param [String] b hi
        def m(*args) end
      eof
    end
    
    it_should_behave_like "all formats"
  end
end
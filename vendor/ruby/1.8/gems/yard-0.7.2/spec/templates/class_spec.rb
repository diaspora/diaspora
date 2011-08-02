require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Engine.template(:default, :docstring) do
  before do
    YARD.parse_string <<-'eof'
      private
      # Comments
      # @abstract override this class
      # @author Test
      # @version 1.0
      # @see A
      # @see http://example.com Example
      class A < B
        # HI
        def method_missing(*args) end
        # @deprecated
        def a; end
        
        # constructor method!
        def initialize(test) end
      end
      
      class C < A; end
      
      class D
        # @private
        def initialize; end
      end
    eof
  end
  
  it "should render html format correctly" do
    html_equals(Registry.at('A').format(:format => :html, :no_highlight => true), :class001)
  end
  
  it "should render text format correctly" do
    text_equals(Registry.at('A').format, :class001)
  end

  it "should hide private constructors" do
    html_equals(Registry.at('D').format(:format => :html, :no_highlight => true, :verifier => Verifier.new("!@private")), :class002)
  end
end
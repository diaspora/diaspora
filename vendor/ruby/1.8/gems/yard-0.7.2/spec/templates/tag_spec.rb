require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Engine.template(:default, :tags) do
  before { Registry.clear }
  
  describe 'all known tags' do
    before do
      YARD.parse_string <<-'eof'
        # Comments
        # @abstract override me
        # @param [Hash] opts the options
        # @option opts :key ('') hello
        # @option opts :key2 (X) hello
        # @return [String] the result
        # @raise [Exception] Exception class
        # @deprecated for great justice
        # @see A
        # @see http://url.com
        # @see http://url.com Example
        # @author Name
        # @since 1.0
        # @version 1.0
        # @yield a block
        # @yieldparam [String] a a value
        # @yieldreturn [Hash] a hash
        # @example Wash your car
        #   car.wash
        # @example To kill a mockingbird
        #   a = String.new
        #   flip(a.reverse)
        def m(opts = {}) end
      eof
    end

    it "should render text format correctly" do
      text_equals(Registry.at('#m').format, :tag001)
    end
  end
end
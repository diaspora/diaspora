require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + "/shared_signature_examples"

describe YARD::Templates::Helpers::TextHelper do
  include YARD::Templates::Helpers::TextHelper
  include YARD::Templates::Helpers::MethodHelper
  
  describe '#signature' do
    before do
      @results = {
        :regular => "root.foo -> Object",
        :default_return => "root.foo -> Hello",
        :no_default_return => "root.foo",
        :private_class => "A.foo -> Object (private)",
        :single => "root.foo -> String",
        :two_types => "root.foo -> (String, Symbol)",
        :two_types_multitag => "root.foo -> (String, Symbol)",
        :type_nil => "root.foo -> Type?",
        :type_array => "root.foo -> Type+",
        :multitype => "root.foo -> (Type, ...)",
        :void => "root.foo -> void",
        :hide_void => "root.foo",
        :block => "root.foo {|a, b, c| ... } -> Object",
        :empty_overload => 'root.foobar -> String'
      }
    end
    
    def signature(obj) super(obj).strip end
    
    it_should_behave_like "signature"
  end

  describe '#align_right' do
    it "should align text right" do
      text = "Method: #some_method (SomeClass)"
      align_right(text).should == ' ' * 40 + text
    end

    it "should truncate text that is longer than allowed width" do
      text = "(Defined in: /home/user/.rip/.packages/some_gem-2460672e333ac07b9190ade88ec9a91c/long/path.rb)"
      align_right(text).should == ' ' + text[0,68] + '...'
    end
  end
end
require 'spec_helper'
require 'cucumber/rb_support/rb_transform'

module Cucumber
  module RbSupport
    describe RbTransform do
      def transform(regexp)
        RbTransform.new(nil, regexp, lambda { |a| })
      end
      describe "#to_s" do
        it "removes the capture group parentheses" do
          transform(/(a)bc/).to_s.should == "abc"
        end
        
        it "strips away anchors" do
          transform(/^xyz$/).to_s.should == "xyz"
        end
      end
    end
  end
end
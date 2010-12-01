require 'spec_helper'
require 'gherkin/formatter/colors'

module Gherkin
  module Formatter
    describe Colors do
      include Gherkin::Formatter::Colors

      it "should colour stuff red" do
        failed("hello").should == "\e[31mhello\e[0m"
      end

      it "should be possible to specify no colouring" do
        uncolored(failed("hello")).should == "hello"
      end
    end
  end
end

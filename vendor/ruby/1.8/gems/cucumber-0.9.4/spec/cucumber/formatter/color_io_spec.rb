require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/formatter/color_io'

module Cucumber
  module Formatter
    describe ColorIO do
      describe "<<" do
        it "should convert to a print using kernel" do
          kernel = mock('Kernel')
          color_io = ColorIO.new(kernel, nil)
          
          kernel.should_receive(:print).with("monkeys")
          
          color_io << "monkeys"
        end
        
        it "should allow chained <<" do
          kernel = mock('Kernel')
          color_io = ColorIO.new(kernel, nil)

          kernel.should_receive(:print).with("monkeys")
          kernel.should_receive(:print).with(" are tasty")
          
          color_io << "monkeys" <<  " are tasty"
        end
      end
    end
  end
end

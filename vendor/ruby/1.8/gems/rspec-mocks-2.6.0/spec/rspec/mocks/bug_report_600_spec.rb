require 'spec_helper'

module BugReport600
  describe "stubbing a class method" do
    class ExampleClass
      def self.method_that_uses_define_method
        define_method "defined_method" do |attributes|
          load_address(address, attributes)
        end
      end
    end
 
    it "works" do
      ExampleClass.should_receive(:define_method).with("defined_method")
      ExampleClass.method_that_uses_define_method
    end

    it "restores the original method" do
      ExampleClass.method_that_uses_define_method
    end
  end
end
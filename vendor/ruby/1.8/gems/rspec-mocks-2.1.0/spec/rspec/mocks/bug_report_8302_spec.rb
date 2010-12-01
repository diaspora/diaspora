require 'spec_helper'

module Bug8302
  describe "Bug report 8302:" do
    class Foo
      def Foo.class_method(arg)
      end
  
      def instance_bar(arg)
      end
    end

    it "class method is not restored correctly when proxied" do
      Foo.should_not_receive(:class_method).with(Array.new)
      Foo.rspec_verify
      Foo.class_method(Array.new)
    end

    it "instance method is not restored correctly when proxied" do
      foo = Foo.new
      foo.should_not_receive(:instance_bar).with(Array.new)
      foo.rspec_verify
      foo.instance_bar(Array.new)
    end
  end
end

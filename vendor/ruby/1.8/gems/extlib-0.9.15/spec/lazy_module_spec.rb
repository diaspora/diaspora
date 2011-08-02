require 'spec_helper'
require 'extlib/lazy_module'

describe LazyModule do
  describe "instantiated with a block" do
    it "defers block body evaluation" do
      lambda do
        LazyModule.new do
          raise "Will only be evaluated when mixed in"
        end
      end.should_not raise_error
    end
  end


  describe "included into hosting class" do
    before :all do
      KlazzyLazyModule = LazyModule.new do
        def self.klassy
          "Klazz"
        end

        def instancy
          "Instanzz"
        end
      end

      @klass = Class.new do
        include KlazzyLazyModule
      end
    end

    it "class evals block body" do
      @klass.klassy.should == "Klazz"
      @klass.new.instancy.should == "Instanzz"
    end
  end
end

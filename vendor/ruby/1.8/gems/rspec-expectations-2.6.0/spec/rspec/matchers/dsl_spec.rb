require 'spec_helper'

module RSpec
  module Matchers
    module DSL
      describe "#define" do
        it "creates a method that initializes a new matcher with the submitted name and expected arg" do
          # FIXME - this expects new to be called, but we need something
          # more robust - that expects new to be called with a specific
          # block (lambda, proc, whatever)
          mod = Module.new
          mod.extend RSpec::Matchers::DSL
          mod.define(:foo)
    
          obj = Object.new
          obj.extend mod
    
          RSpec::Matchers::Matcher.should_receive(:new).with(:foo, 3) { stub('matcher').as_null_object }

          obj.foo(3)
        end
      end
    end
  end
end

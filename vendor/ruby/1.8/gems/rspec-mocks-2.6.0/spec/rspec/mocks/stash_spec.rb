require 'spec_helper'

module RSpec
  module Mocks

    describe "only stashing the original method" do
      let(:klass) do
        Class.new do
          def self.foo(arg)
            :original_value
          end
        end
      end
      it "keeps the original method intact after multiple expectations are added on the same method" do
        klass.should_receive(:foo).with(:fizbaz).and_return(:wowwow)
        klass.should_receive(:foo).with(:bazbar).and_return(:okay)

        klass.foo(:fizbaz)
        klass.foo(:bazbar)
        klass.rspec_verify

        klass.rspec_reset
        klass.foo(:yeah).should equal(:original_value)
      end
    end
  end
end

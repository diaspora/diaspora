require 'spec_helper'
require 'yaml'

module RSpec
  module Mocks
    class SerializableStruct < Struct.new(:foo, :bar); end

    describe Serialization do
      def self.with_yaml_loaded(&block)
        context 'with YAML loaded' do
          module_eval(&block)
        end
      end

      def self.without_yaml_loaded(&block)
        context 'without YAML loaded' do
          before(:each) do
            # We can't really unload yaml, but we can fake it here...
            @orig_yaml_constant = Object.send(:remove_const, :YAML)
            Struct.class_eval do
              alias __old_to_yaml to_yaml
              undef to_yaml
            end
          end

          module_eval(&block)

          after(:each) do
            Object.const_set(:YAML, @orig_yaml_constant)
            Struct.class_eval do
              alias to_yaml __old_to_yaml
              undef __old_to_yaml
            end
          end
        end
      end

      subject { SerializableStruct.new(7, "something") }

      def set_stub
        subject.stub(:bazz => 5)
      end

      with_yaml_loaded do
        it 'serializes to yaml the same with and without stubbing, using #to_yaml' do
          expect { set_stub }.to_not change { subject.to_yaml }
        end

        it 'serializes to yaml the same with and without stubbing, using YAML.dump' do
          expect { set_stub }.to_not change { YAML.dump(subject) }
        end
      end

      without_yaml_loaded do
        it 'does not add #to_yaml to the stubbed object' do
          subject.should_not respond_to(:to_yaml)
          set_stub
          subject.should_not respond_to(:to_yaml)
        end
      end

      it 'marshals the same with and without stubbing' do
        expect { set_stub }.to_not change { Marshal.dump(subject) }
      end
    end
  end
end

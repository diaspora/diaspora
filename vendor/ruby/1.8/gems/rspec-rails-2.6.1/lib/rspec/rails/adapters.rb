require 'active_support/concern'
require 'test/unit/assertions'

module RSpec
  module Rails
    module SetupAndTeardownAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        def setup(*methods)
          methods.each {|method| before { send method } }
        end

        def teardown(*methods)
          methods.each {|method| after { send method } }
        end
      end

      module InstanceMethods
        def method_name
          @example
        end
      end
    end

    module TestUnitAssertionAdapter
      extend ActiveSupport::Concern

      class AssertionDelegate
        include Test::Unit::Assertions
      end

      module ClassMethods
        def assertion_method_names
          Test::Unit::Assertions.public_instance_methods.select{|m| m.to_s =~ /^(assert|flunk)/} +
            [:build_message]
        end

        def define_assertion_delegators
          assertion_method_names.each do |m|
            class_eval <<-CODE
              def #{m}(*args, &block)
                assertion_delegate.send :#{m}, *args, &block
              end
            CODE
          end
        end
      end

      module InstanceMethods
        def assertion_delegate
          @assertion_delegate ||= AssertionDelegate.new
        end
      end

      included do
        define_assertion_delegators
      end
    end
  end
end

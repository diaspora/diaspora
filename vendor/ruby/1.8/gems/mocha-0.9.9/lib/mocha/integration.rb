module Mocha
  
  module Integration
    
    class << self
    
      def monkey_patches
        patches = []
        if test_unit_testcase_defined? && !test_unit_testcase_inherits_from_miniunit_testcase?
          patches << 'mocha/integration/test_unit'
        end
        if mini_unit_testcase_defined?
          patches << 'mocha/integration/mini_test'
        end
        patches
      end
      
      def test_unit_testcase_defined?
        defined?(Test) && defined?(Test::Unit) && defined?(Test::Unit::TestCase)
      end
      
      def mini_unit_testcase_defined?
        defined?(MiniTest) && defined?(MiniTest::Unit) && defined?(MiniTest::Unit::TestCase)
      end
      
      def test_unit_testcase_inherits_from_miniunit_testcase?
        test_unit_testcase_defined? && mini_unit_testcase_defined? && Test::Unit::TestCase.ancestors.include?(MiniTest::Unit::TestCase)
      end
      
    end
    
  end
  
end

Mocha::Integration.monkey_patches.each do |patch|
  require patch
end

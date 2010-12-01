require 'mocha/expectation_error'

module Mocha
  
  module Integration
    
    module MiniTest
      
      def self.translate(exception)
        return exception unless exception.kind_of?(::Mocha::ExpectationError)
        translated_exception = ::MiniTest::Assertion.new(exception.message)
        translated_exception.set_backtrace(exception.backtrace)
        translated_exception
      end
      
    end
    
  end
  
end

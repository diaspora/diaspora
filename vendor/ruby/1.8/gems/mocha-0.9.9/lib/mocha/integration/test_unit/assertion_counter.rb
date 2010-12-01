module Mocha
  
  module Integration
    
    module TestUnit
      
      class AssertionCounter
        
        def initialize(test_result)
          @test_result = test_result
        end
        
        def increment
          @test_result.add_assertion
        end
        
      end
      
    end
    
  end
  
end
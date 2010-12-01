module Mocha
  
  module Integration
    
    module MiniTest
      
      class AssertionCounter
        
        def initialize(test_case)
          @test_case = test_case
        end
        
        def increment
          @test_case._assertions += 1
        end
        
      end
      
    end
    
  end
  
end

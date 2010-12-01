require 'mocha/integration/mini_test/assertion_counter'

module Mocha
  
  module Integration
    
    module MiniTest
      
      module Version13
        def self.included(mod)
          $stderr.puts "Monkey patching MiniTest v1.3" if $options['debug']
        end
        def run runner
          assertion_counter = AssertionCounter.new(self)
          result = '.'
          begin
            begin
              @passed = nil
              self.setup
              self.__send__ self.name
              mocha_verify(assertion_counter)
              @passed = true
            rescue Exception => e
              @passed = false
              result = runner.puke(self.class, self.name, Mocha::Integration::MiniTest.translate(e))
            ensure
              begin
                self.teardown
              rescue Exception => e
                result = runner.puke(self.class, self.name, Mocha::Integration::MiniTest.translate(e))
              end
            end
          ensure
            mocha_teardown
          end
          result
        end
      end
      
    end
    
  end
  
end

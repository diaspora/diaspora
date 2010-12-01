require 'mocha/integration/mini_test/assertion_counter'
require 'mocha/expectation_error'

module Mocha
  
  module Integration
    
    module MiniTest
            
      module Version141
        def self.included(mod)
          $stderr.puts "Monkey patching MiniTest v1.4.1"
        end
        def run runner
          trap 'INFO' do
            warn '%s#%s %.2fs' % [self.class, self.__name__,
              (Time.now - runner.start_time)]
            runner.status $stderr
          end

          assertion_counter = AssertionCounter.new(self)
          result = '.'
          begin
            begin
              @passed = nil
              self.setup
              self.__send__ self.__name__
              mocha_verify(assertion_counter)
              @passed = true
            rescue *::MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS
              raise
            rescue Exception => e
              @passed = false
              result = runner.puke(self.class, self.__name__, Mocha::Integration::MiniTest.translate(e))
            ensure
              begin
                self.teardown
              rescue *::MiniTest::Unit::TestCase::PASSTHROUGH_EXCEPTIONS
                raise
              rescue Exception => e
                result = runner.puke(self.class, self.__name__, Mocha::Integration::MiniTest.translate(e))
              end
              trap 'INFO', 'DEFAULT'
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

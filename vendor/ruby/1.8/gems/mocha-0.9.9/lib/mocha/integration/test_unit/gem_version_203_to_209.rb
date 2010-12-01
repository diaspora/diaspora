require 'test/unit/testcase'
require 'mocha/integration/test_unit/assertion_counter'
require 'mocha/expectation_error'

module Mocha
  
  module Integration
    
    module TestUnit
      
      module GemVersion203To209
        def self.included(mod)
          $stderr.puts "Monkey patching Test::Unit gem >= v2.0.3 and <= v2.0.9" if $options['debug']
        end
        def run(result)
          assertion_counter = AssertionCounter.new(result)
          begin
            @_result = result
            yield(Test::Unit::TestCase::STARTED, name)
            begin
              begin
                run_setup
                run_test
                mocha_verify(assertion_counter)
              rescue Mocha::ExpectationError => e
                add_failure(e.message, e.backtrace)
              rescue Exception
                @interrupted = true
                raise unless handle_exception($!)
              ensure
                begin
                  run_teardown
                rescue Exception
                  raise unless handle_exception($!)
                end
              end
            ensure
              mocha_teardown
            end
            result.add_run
            yield(Test::Unit::TestCase::FINISHED, name)
          ensure
            # @_result = nil # For test-spec's after_all :<
          end
        end
      end
      
    end
    
  end
  
end

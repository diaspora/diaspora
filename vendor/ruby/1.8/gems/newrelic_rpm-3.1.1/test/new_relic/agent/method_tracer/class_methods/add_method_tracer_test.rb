require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','test_helper'))

require 'set'
module NewRelic
  module Agent
    class Agent
      module MethodTracer
        module ClassMethods
          class AddMethodTracerTest < Test::Unit::TestCase
            #  require 'new_relic/agent/method_tracer'
            include NewRelic::Agent::MethodTracer::ClassMethods::AddMethodTracer

            def test_validate_options_nonhash
              assert_raise(TypeError) do
                validate_options([])
              end
            end

            def test_validate_options_defaults
              self.expects(:check_for_illegal_keys!)
              self.expects(:set_deduct_call_time_based_on_metric).with(DEFAULT_SETTINGS)
              self.expects(:check_for_push_scope_and_metric)
              validate_options({})
            end

            def test_validate_options_override
              opts = {:push_scope => false, :metric => false, :force => true}
              self.expects(:check_for_illegal_keys!)
              self.expects(:check_for_push_scope_and_metric)
              val = validate_options(opts)
              assert val.is_a?(Hash)
              assert (val[:push_scope] == false), val.inspect
              assert (val[:metric] == false), val.inspect
              assert (val[:force] == true), val.inspect
            end

            def test_default_metric_name_code
              assert_equal "Custom/#{name}/test_method", default_metric_name_code('test_method')
            end

            def test_newrelic_method_exists_positive
              self.expects(:method_defined?).returns(true)
              assert newrelic_method_exists?('test_method')
            end

            def test_newrelic_method_exists_negative
              self.expects(:method_defined?).returns(false)
              self.expects(:private_method_defined?).returns(false)

              fake_log = mock('log')
              NewRelic::Control.instance.expects(:log).returns(fake_log)
              fake_log.expects(:warn).with("Did not trace #{name}#test_method because that method does not exist")
              assert !newrelic_method_exists?('test_method')
            end

            def test_set_deduct_call_time_based_on_metric_positive
              opts = {:metric => true}
              val = set_deduct_call_time_based_on_metric(opts)
              assert val.is_a?(Hash)
              assert val[:deduct_call_time_from_parent]
            end

            def test_set_deduct_call_time_based_on_metric_negative
              opts = {:metric => false}
              val = set_deduct_call_time_based_on_metric(opts)
              assert val.is_a?(Hash)
              assert !val[:deduct_call_time_from_parent]
            end

            def test_set_deduct_call_time_based_on_metric_non_nil
              opts = {:deduct_call_time_from_parent => true, :metric => false}
              val = set_deduct_call_time_based_on_metric(opts)
              assert val.is_a?(Hash)
              assert val[:deduct_call_time_from_parent]
            end

            def test_set_deduct_call_time_based_on_metric_opposite
              opts = {:deduct_call_time_from_parent => false, :metric => true}
              val = set_deduct_call_time_based_on_metric(opts)
              assert val.is_a?(Hash)
              assert !val[:deduct_call_time_from_parent]
            end

            def test_unrecognized_keys_positive
              assert_equal [:unrecognized, :keys].to_set, unrecognized_keys([:hello, :world], {:unrecognized => nil, :keys => nil}).to_set
            end

            def test_unrecognized_keys_negative
              assert_equal [], unrecognized_keys([:hello, :world], {:hello => nil, :world => nil})
            end

            def test_any_unrecognized_keys_positive
              assert any_unrecognized_keys?([:one], {:one => nil, :two => nil})
            end

            def test_any_unrecognized_keys_negative
              assert !any_unrecognized_keys?([:one], {:one => nil})
            end

            def test_check_for_illegal_keys_positive
              assert_raise(RuntimeError) do
                check_for_illegal_keys!({:unknown_key => nil})
              end
            end

            def test_check_for_illegal_keys_negative
              test_keys = Hash[ALLOWED_KEYS.map {|x| [x, nil]}]
              check_for_illegal_keys!(test_keys)
            end

            def test_traced_method_exists_positive
              self.expects(:_traced_method_name)
              self.expects(:method_defined?).returns(true)
              fake_log = mock('log')
              NewRelic::Control.instance.expects(:log).returns(fake_log)
              fake_log.expects(:warn).with('Attempt to trace a method twice with the same metric: Method = test_method, Metric Name = Custom/Test/test_method')
              assert traced_method_exists?('test_method', 'Custom/Test/test_method')
            end

            def test_traced_method_exists_negative
              self.expects(:_traced_method_name)
              self.expects(:method_defined?).returns(false)
              assert !traced_method_exists?(nil, nil)
            end

            def test_assemble_code_header_forced
              opts = {:force => true, :code_header => 'CODE HEADER'}
              assert_equal "CODE HEADER", assemble_code_header('test_method', 'Custom/Test/test_method', opts)
            end

            def test_assemble_code_header_unforced
              self.expects(:_untraced_method_name).returns("method_name_without_tracing")
              opts = {:force => false, :code_header => 'CODE HEADER'}
              assert_equal "return method_name_without_tracing(*args, &block) unless NewRelic::Agent.is_execution_traced?\nCODE HEADER", assemble_code_header('test_method', 'Custom/Test/test_method', opts)
            end

            def test_check_for_push_scope_and_metric_positive
              check_for_push_scope_and_metric({:push_scope => true})
              check_for_push_scope_and_metric({:metric => true})
            end

            def test_check_for_push_scope_and_metric_negative
              assert_raise(RuntimeError) do
                check_for_push_scope_and_metric({:push_scope => false, :metric => false})
              end
            end

            def test_code_to_eval_scoped
              self.expects(:validate_options).returns({:push_scope => true})
              self.expects(:method_with_push_scope).with('test_method', 'Custom/Test/test_method', {:push_scope => true})
              code_to_eval('test_method', 'Custom/Test/test_method', {})
            end

            def test_code_to_eval_unscoped
              self.expects(:validate_options).returns({:push_scope => false})
              self.expects(:method_without_push_scope).with('test', 'Custom/Test/test', {:push_scope => false})
              code_to_eval('test', 'Custom/Test/test', {})
            end
          end
        end
      end
    end
  end
end

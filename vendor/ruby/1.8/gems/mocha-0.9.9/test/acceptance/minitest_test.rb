require File.expand_path('../acceptance_test_helper', __FILE__)

if defined?(MiniTest)
  $stderr.puts "TODO: Running suite with MiniTest, running the MiniTestAdapterTest results in an error so skipping it for now."
else
  begin
    require 'rubygems'
    gem 'minitest'
  rescue Gem::LoadError
    # MiniTest gem not available
  end

  begin
    require 'minitest/unit'
  rescue LoadError
    # MiniTest not available
  end

  if defined?(MiniTest)
  
    # monkey-patch MiniTest now that it has hopefully been loaded
    require 'mocha/integration/mini_test'

    class MiniTestSampleTest < MiniTest::Unit::TestCase
  
      def test_mocha_with_fulfilled_expectation
        mockee = mock()
        mockee.expects(:blah)
        mockee.blah
      end
  
      def test_mocha_with_unfulfilled_expectation
        mockee = mock()
        mockee.expects(:blah)
      end
  
      def test_mocha_with_unexpected_invocation
        mockee = mock()
        mockee.blah
      end
  
      def test_stubba_with_fulfilled_expectation
        stubbee = Class.new { define_method(:blah) {} }.new
        stubbee.expects(:blah)
        stubbee.blah
      end
  
      def test_stubba_with_unfulfilled_expectation
        stubbee = Class.new { define_method(:blah) {} }.new
        stubbee.expects(:blah)
      end
  
      def test_mocha_with_matching_parameter
        mockee = mock()
        mockee.expects(:blah).with(has_key(:wibble))
        mockee.blah(:wibble => 1)
      end
  
      def test_mocha_with_non_matching_parameter
        mockee = mock()
        mockee.expects(:blah).with(has_key(:wibble))
        mockee.blah(:wobble => 2)
      end
  
    end

    class MiniTestTest < Test::Unit::TestCase
  
      def setup
        @output = StringIO.new
        MiniTest::Unit.output = @output
        @runner = MiniTest::Unit.new
      end
  
      attr_reader :runner
  
      def test_should_pass_mocha_test
        runner.run(%w(-n test_mocha_with_fulfilled_expectation))
    
        assert_equal 0, runner.failures
        assert_equal 0, runner.errors
        assert_equal 1, runner.assertion_count
      end

      def test_should_fail_mocha_test_due_to_unfulfilled_expectation
        runner.run(%w(-n test_mocha_with_unfulfilled_expectation))
      
        assert_equal 1, runner.failures
        assert_equal 0, runner.errors
        assert_equal 1, runner.assertion_count
        assert_not_all_expectation_were_satisfied
      end
  
      def test_should_fail_mocha_test_due_to_unexpected_invocation
        runner.run(%w(-n test_mocha_with_unexpected_invocation))
    
        assert_equal 1, runner.failures
        assert_equal 0, runner.errors
        assert_equal 0, runner.assertion_count
        assert_unexpected_invocation
      end
  
      def test_should_pass_stubba_test
        runner.run(%w(-n test_stubba_with_fulfilled_expectation))
    
        assert_equal 0, runner.failures
        assert_equal 0, runner.errors
        assert_equal 1, runner.assertion_count
      end
  
      def test_should_fail_stubba_test_due_to_unfulfilled_expectation
        runner.run(%w(-n test_stubba_with_unfulfilled_expectation))
    
        assert_equal 1, runner.failures
        assert_equal 0, runner.errors
        assert_equal 1, runner.assertion_count
        assert_not_all_expectation_were_satisfied
      end
  
      def test_should_pass_mocha_test_with_matching_parameter
        runner.run(%w(-n test_mocha_with_matching_parameter))
    
        assert_equal 0, runner.failures
        assert_equal 0, runner.errors
        assert_equal 1, runner.assertion_count
      end
  
      def test_should_fail_mocha_test_with_non_matching_parameter
        runner.run(%w(-n test_mocha_with_non_matching_parameter))
      
        assert_equal 1, runner.failures
        assert_equal 0, runner.errors
        assert_equal 0, runner.assertion_count # unexpected invocation occurs before expectation is verified
        assert_unexpected_invocation
      end
  
      private
  
      def output
        @output.rewind
        @output.read
      end
  
      def assert_unexpected_invocation
        assert_match Regexp.new('unexpected invocation'), output, "MiniTest output:\n#{output}"
      end
  
      def assert_not_all_expectation_were_satisfied
        assert_match Regexp.new('not all expectations were satisfied'), output, "MiniTest output:\n#{output}"
      end
  
    end
  
  else
    $stderr.puts "MiniTest is not available, so MiniTestAdapterTest has not been run."
  end
end
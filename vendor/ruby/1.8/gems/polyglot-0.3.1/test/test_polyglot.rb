require File.dirname(__FILE__) + '/test_helper.rb'

class TestPolyglot < Test::Unit::TestCase
  TEST_FILE = 'test_file.stub'
  TEST_REQUIRES_FILE = 'test_requires_file.eval'
  class StubLoader
    def self.load(*args); end
  end
  class EvalLoader
    def self.load(file)
      File.open(file) do |source_file|
        source = source_file.read
        eval source
      end
    end
  end

  def setup
    Polyglot.register('stub', StubLoader)
    File.open(TEST_FILE, 'w') { |f| f.puts "Test data" }
    Polyglot.register('eval', EvalLoader)
    File.open(TEST_REQUIRES_FILE, 'w') { |f| f.puts "require 'nonexistent_file'" }
  end

  def teardown
    File.delete(TEST_FILE)
    File.delete(TEST_REQUIRES_FILE)
  end
  
  def test_load_by_absolute_path
    full_path = File.expand_path(TEST_FILE.sub(/.stub$/, ''))
    assert_nothing_raised { require full_path }
  end
  
  def test_load_error
    exception = assert_raise(LoadError) { require "nonexistent_file" }
    assert_match(/nonexistent_file/, exception.message)
  end
  
  def test_load_error_inside_poly_file
    exception = assert_raise(LoadError) { require TEST_REQUIRES_FILE.sub(/.eval$/, '') }
    assert_match(/nonexistent_file/, exception.message)
  end
end

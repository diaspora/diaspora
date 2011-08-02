#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize module
class TestHashFormat < Test::Unit::TestCase
  TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                          '..', 'lib')
  require File.join(TOP_SRC_DIR, 'columnize.rb')
  include Columnize
  def test_parse_columnize_options
    list, default_opts = parse_columnize_options([[], {}])
    assert list.kind_of?(Array)
    assert default_opts.kind_of?(Hash)
    list, opts = parse_columnize_options([[], 90])
    assert_equal 90, opts[:displaywidth]
    list, opts = parse_columnize_options([[], 70, '|'])
    assert_equal 70, opts[:displaywidth]
    assert_equal '|', opts[:colsep]
  end

  def test_parse_columnize_ljust
    list, opts = parse_columnize_options([[1.5, 2, 3], {:ljust => :auto}])
    assert_equal false, opts[:ljust]
    list, opts = parse_columnize_options([[1.5, 2, 3], {:ljust => false}])
    assert_equal false, opts[:ljust]
    list, opts = parse_columnize_options([[1.5, 2, 3], {:ljust => true}])
    assert_equal true, opts[:ljust]
    list, opts = parse_columnize_options([[1, 2, 'b'], {:ljust => :auto}])
    assert_equal true, opts[:ljust]
  end

  def test_new_hash
    list, opts = parse_columnize_options([[], {:displaywidth => 40,
                                          :colsep => ', ',
                                          :term_adjust => true,
                                          }])
    [[:displaywidth, 40], [:colsep, ', '], [:term_adjust, true]].each do 
       |field, value|
       assert_equal(value , opts[field])
     end
    list, opts = parse_columnize_options([[], {:displaywidth => 40,
                                          :colsep => ', ',
                                          }])
    assert_equal(false , opts[:term_adjust])
    opts = {:colsep => ', '}
    assert_equal("1, 2, 3\n", 
                 Columnize::columnize([1, 2, 3], opts))
  end
  
  def test_array
    data = (0..54).to_a
    assert_equal(
            "[ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9\n" +
            " 10, 11, 12, 13, 14, 15, 16, 17, 18, 19\n" +
            " 20, 21, 22, 23, 24, 25, 26, 27, 28, 29\n" +
            " 30, 31, 32, 33, 34, 35, 36, 37, 38, 39\n" +
            " 40, 41, 42, 43, 44, 45, 46, 47, 48, 49\n" +
            " 50, 51, 52, 53, 54\n" + 
             "]\n",
            columnize(data, 
                      :arrange_array => true, :ljust => false,
                      :displaywidth  => 39))
  end

  def test_justify
    data = (0..54).to_a
    assert_equal(
            "[ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9\n" +
            " 10, 11, 12, 13, 14, 15, 16, 17, 18, 19\n" +
            " 20, 21, 22, 23, 24, 25, 26, 27, 28, 29\n" +
            " 30, 31, 32, 33, 34, 35, 36, 37, 38, 39\n" +
            " 40, 41, 42, 43, 44, 45, 46, 47, 48, 49\n" +
            " 50, 51, 52, 53, 54\n" + 
             "]\n",
            columnize(data, 
                      :arrange_array => true,
                      :displaywidth  => 39))
  end

end

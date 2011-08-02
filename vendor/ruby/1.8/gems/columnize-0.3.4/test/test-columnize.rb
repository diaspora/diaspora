#!/usr/bin/env ruby
require 'test/unit'

# Test of Columnize module
class TestColumnize < Test::Unit::TestCase
  @@TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 
                            '..', 'lib')
  require File.join(@@TOP_SRC_DIR, 'columnize.rb')
  include Columnize
  
  def test_cell_size
    assert_equal(3, cell_size('abc', false))
    assert_equal(3, cell_size('abc', true))
    assert_equal(6, cell_size("\e[0;31mObject\e[0;4m", true))
    assert_equal(19, cell_size("\e[0;31mObject\e[0;4m", false))
  end

  # test columnize
  def test_basic
    # Try at least one test where we give the module name explicitely.
    assert_equal("1, 2, 3\n", 
                 Columnize::columnize([1, 2, 3], 10, ', '))
    assert_equal("", columnize(5))
    assert_equal("1  3\n2  4\n", 
                 columnize(['1', '2', '3', '4'], 4))
    assert_equal("1  2\n3  4\n", 
                 columnize(['1', '2', '3', '4'], 4, '  ', false))
    assert_equal("<empty>\n", columnize([]))
    
    
    assert_equal("oneitem\n", columnize(["oneitem"]))
    
    data = (0..54).map{|i| i.to_s}
    assert_equal(
            "0,  6, 12, 18, 24, 30, 36, 42, 48, 54\n" + 
            "1,  7, 13, 19, 25, 31, 37, 43, 49\n" +
            "2,  8, 14, 20, 26, 32, 38, 44, 50\n" +
            "3,  9, 15, 21, 27, 33, 39, 45, 51\n" +
            "4, 10, 16, 22, 28, 34, 40, 46, 52\n" +
            "5, 11, 17, 23, 29, 35, 41, 47, 53\n",
            columnize(data, 39, ', ', true, false))

    assert_equal(
            " 0,  1,  2,  3,  4,  5,  6,  7,  8,  9\n" +
            "10, 11, 12, 13, 14, 15, 16, 17, 18, 19\n" +
            "20, 21, 22, 23, 24, 25, 26, 27, 28, 29\n" +
            "30, 31, 32, 33, 34, 35, 36, 37, 38, 39\n" +
            "40, 41, 42, 43, 44, 45, 46, 47, 48, 49\n" +
            "50, 51, 52, 53, 54\n",
            columnize(data, 39, ', ', false, false))


    assert_equal(
            "   0,  1,  2,  3,  4,  5,  6,  7,  8\n" +
            "   9, 10, 11, 12, 13, 14, 15, 16, 17\n" +
            "  18, 19, 20, 21, 22, 23, 24, 25, 26\n" +
            "  27, 28, 29, 30, 31, 32, 33, 34, 35\n" +
            "  36, 37, 38, 39, 40, 41, 42, 43, 44\n" +
            "  45, 46, 47, 48, 49, 50, 51, 52, 53\n" +
            "  54\n",
            columnize(data, 39, ', ', false, false, '  '))


    data = ["one",       "two",         "three",
            "for",       "five",        "six",
            "seven",     "eight",       "nine",
            "ten",       "eleven",      "twelve",
            "thirteen",  "fourteen",    "fifteen",
            "sixteen",   "seventeen",   "eightteen",
            "nineteen",  "twenty",      "twentyone",
            "twentytwo", "twentythree", "twentyfour",
            "twentyfive","twentysix",   "twentyseven"]

     assert_equal(
"one         two         three        for          five         six        \n" +
"seven       eight       nine         ten          eleven       twelve     \n" +
"thirteen    fourteen    fifteen      sixteen      seventeen    eightteen  \n" +
"nineteen    twenty      twentyone    twentytwo    twentythree  twentyfour \n" +
"twentyfive  twentysix   twentyseven\n", columnize(data, 80, '  ', false))

    assert_equal(
"one    five   nine    thirteen  seventeen  twentyone    twentyfive \n" +
"two    six    ten     fourteen  eightteen  twentytwo    twentysix  \n" +
"three  seven  eleven  fifteen   nineteen   twentythree  twentyseven\n" +
"for    eight  twelve  sixteen   twenty     twentyfour \n", columnize(data))

  end
end

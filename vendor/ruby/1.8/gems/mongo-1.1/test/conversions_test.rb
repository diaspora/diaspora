require './test/test_helper'
require 'mongo/exceptions'
require 'mongo/util/conversions'
require 'bson/ordered_hash'

class ConversionsTest < Test::Unit::TestCase
  include Mongo::Conversions

  def test_array_as_sort_parameters_with_array_of_key_and_value
    params = array_as_sort_parameters(["field1", "asc"])
    assert_equal({"field1" => 1}, params)
  end

  def test_array_as_sort_parameters_with_array_of_string_and_values
    params = array_as_sort_parameters([["field1", :asc], ["field2", :desc]])
    assert_equal({ "field1" => 1, "field2" => -1 }, params)
  end

  def test_string_as_sort_parameters_with_string
    params = string_as_sort_parameters("field")
    assert_equal({ "field" => 1 }, params)
  end

  def test_string_as_sort_parameters_with_empty_string
    params = string_as_sort_parameters("")
    assert_equal({}, params)
  end

  def test_symbol_as_sort_parameters
    params = string_as_sort_parameters(:field)
    assert_equal({ "field" => 1 }, params)
  end

  def test_sort_value_when_value_is_one
    assert_equal 1, sort_value(1)
  end

  def test_sort_value_when_value_is_one_as_a_string
    assert_equal 1, sort_value("1")
  end

  def test_sort_value_when_value_is_negative_one
    assert_equal -1, sort_value(-1)
  end

  def test_sort_value_when_value_is_negative_one_as_a_string
    assert_equal -1, sort_value("-1")
  end

  def test_sort_value_when_value_is_ascending
    assert_equal 1, sort_value("ascending")
  end

  def test_sort_value_when_value_is_asc
    assert_equal 1, sort_value("asc")
  end

  def test_sort_value_when_value_is_uppercase_ascending
    assert_equal 1, sort_value("ASCENDING")
  end

  def test_sort_value_when_value_is_uppercase_asc
    assert_equal 1, sort_value("ASC")
  end

  def test_sort_value_when_value_is_symbol_ascending
    assert_equal 1, sort_value(:ascending)
  end

  def test_sort_value_when_value_is_symbol_asc
    assert_equal 1, sort_value(:asc)
  end

  def test_sort_value_when_value_is_symbol_uppercase_ascending
    assert_equal 1, sort_value(:ASCENDING)
  end

  def test_sort_value_when_value_is_symbol_uppercase_asc
    assert_equal 1, sort_value(:ASC)
  end

  def test_sort_value_when_value_is_descending
    assert_equal -1, sort_value("descending")
  end

  def test_sort_value_when_value_is_desc
    assert_equal -1, sort_value("desc")
  end

  def test_sort_value_when_value_is_uppercase_descending
    assert_equal -1, sort_value("DESCENDING")
  end

  def test_sort_value_when_value_is_uppercase_desc
    assert_equal -1, sort_value("DESC")
  end

  def test_sort_value_when_value_is_symbol_descending
    assert_equal -1, sort_value(:descending)
  end

  def test_sort_value_when_value_is_symbol_desc
    assert_equal -1, sort_value(:desc)
  end

  def test_sort_value_when_value_is_uppercase_symbol_descending
    assert_equal -1, sort_value(:DESCENDING)
  end

  def test_sort_value_when_value_is_uppercase_symbol_desc
    assert_equal -1, sort_value(:DESC)
  end

  def test_sort_value_when_value_is_invalid
    assert_raise Mongo::InvalidSortValueError do
      sort_value(2)
    end
  end

end

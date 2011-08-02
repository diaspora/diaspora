#!/usr/local/bin/ruby -w

# tc_csv_parsing.rb
#
#  Created by James Edward Gray II on 2005-10-31.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "faster_csv"

# 
# Following tests are my interpretation of the 
# {CSV RCF}[http://www.ietf.org/rfc/rfc4180.txt].  I only deviate from that 
# document in one place (intentionally) and that is to make the default row
# separator <tt>$/</tt>.
# 
class TestCSVParsing < Test::Unit::TestCase
  def test_mastering_regex_example
    ex = %Q{Ten Thousand,10000, 2710 ,,"10,000","It's ""10 Grand"", baby",10K}
    assert_equal( [ "Ten Thousand", "10000", " 2710 ", nil, "10,000",
                    "It's \"10 Grand\", baby", "10K" ],
                  FasterCSV.parse_line(ex) )
  end
  
  # Pulled from:  http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/ruby/test/csv/test_csv.rb?rev=1.12.2.2;content-type=text%2Fplain
  def test_std_lib_csv
    [ ["\t", ["\t"]],
      ["foo,\"\"\"\"\"\",baz", ["foo", "\"\"", "baz"]],
      ["foo,\"\"\"bar\"\"\",baz", ["foo", "\"bar\"", "baz"]],
      ["\"\"\"\n\",\"\"\"\n\"", ["\"\n", "\"\n"]],
      ["foo,\"\r\n\",baz", ["foo", "\r\n", "baz"]],
      ["\"\"", [""]],
      ["foo,\"\"\"\",baz", ["foo", "\"", "baz"]],
      ["foo,\"\r.\n\",baz", ["foo", "\r.\n", "baz"]],
      ["foo,\"\r\",baz", ["foo", "\r", "baz"]],
      ["foo,\"\",baz", ["foo", "", "baz"]],
      ["\",\"", [","]],
      ["foo", ["foo"]],
      [",,", [nil, nil, nil]],
      [",", [nil, nil]],
      ["foo,\"\n\",baz", ["foo", "\n", "baz"]],
      ["foo,,baz", ["foo", nil, "baz"]],
      ["\"\"\"\r\",\"\"\"\r\"", ["\"\r", "\"\r"]],
      ["\",\",\",\"", [",", ","]],
      ["foo,bar,", ["foo", "bar", nil]],
      [",foo,bar", [nil, "foo", "bar"]],
      ["foo,bar", ["foo", "bar"]],
      [";", [";"]],
      ["\t,\t", ["\t", "\t"]],
      ["foo,\"\r\n\r\",baz", ["foo", "\r\n\r", "baz"]],
      ["foo,\"\r\n\n\",baz", ["foo", "\r\n\n", "baz"]],
      ["foo,\"foo,bar\",baz", ["foo", "foo,bar", "baz"]],
      [";,;", [";", ";"]] ].each do |csv_test|
      assert_equal(csv_test.last, FasterCSV.parse_line(csv_test.first))
    end

    [ ["foo,\"\"\"\"\"\",baz", ["foo", "\"\"", "baz"]],
      ["foo,\"\"\"bar\"\"\",baz", ["foo", "\"bar\"", "baz"]],
      ["foo,\"\r\n\",baz", ["foo", "\r\n", "baz"]],
      ["\"\"", [""]],
      ["foo,\"\"\"\",baz", ["foo", "\"", "baz"]],
      ["foo,\"\r.\n\",baz", ["foo", "\r.\n", "baz"]],
      ["foo,\"\r\",baz", ["foo", "\r", "baz"]],
      ["foo,\"\",baz", ["foo", "", "baz"]],
      ["foo", ["foo"]],
      [",,", [nil, nil, nil]],
      [",", [nil, nil]],
      ["foo,\"\n\",baz", ["foo", "\n", "baz"]],
      ["foo,,baz", ["foo", nil, "baz"]],
      ["foo,bar", ["foo", "bar"]],
      ["foo,\"\r\n\n\",baz", ["foo", "\r\n\n", "baz"]],
      ["foo,\"foo,bar\",baz", ["foo", "foo,bar", "baz"]] ].each do |csv_test|
      assert_equal(csv_test.last, FasterCSV.parse_line(csv_test.first))
    end
  end
  
  # From:  http://ruby-talk.org/cgi-bin/scat.rb/ruby/ruby-core/6496
  def test_aras_edge_cases
    [ [%Q{a,b},               ["a", "b"]],
      [%Q{a,"""b"""},         ["a", "\"b\""]],
      [%Q{a,"""b"},           ["a", "\"b"]],
      [%Q{a,"b"""},           ["a", "b\""]],
      [%Q{a,"\nb"""},         ["a", "\nb\""]],
      [%Q{a,"""\nb"},         ["a", "\"\nb"]],
      [%Q{a,"""\nb\n"""},     ["a", "\"\nb\n\""]],
      [%Q{a,"""\nb\n""",\nc}, ["a", "\"\nb\n\"", nil]],
      [%Q{a,,,},              ["a", nil, nil, nil]],
      [%Q{,},                 [nil, nil]],
      [%Q{"",""},             ["", ""]],
      [%Q{""""},              ["\""]],
      [%Q{"""",""},           ["\"",""]],
      [%Q{,""},               [nil,""]],
      [%Q{,"\r"},             [nil,"\r"]],
      [%Q{"\r\n,"},           ["\r\n,"]],
      [%Q{"\r\n,",},          ["\r\n,", nil]] ].each do |edge_case|
        assert_equal(edge_case.last, FasterCSV.parse_line(edge_case.first))
      end
  end
  
  def test_james_edge_cases
    # A read at eof? should return nil.
    assert_equal(nil, FasterCSV.parse_line(""))
    # 
    # With CSV it's impossible to tell an empty line from a line containing a
    # single +nil+ field.  The standard CSV library returns <tt>[nil]</tt>
    # in these cases, but <tt>Array.new</tt> makes more sense to me.
    # 
    assert_equal(Array.new, FasterCSV.parse_line("\n1,2,3\n"))
  end

  def test_rob_edge_cases
    [ [%Q{"a\nb"},                         ["a\nb"]],
      [%Q{"\n\n\n"},                       ["\n\n\n"]],
      [%Q{a,"b\n\nc"},                     ['a', "b\n\nc"]],
      [%Q{,"\r\n"},                        [nil,"\r\n"]],
      [%Q{,"\r\n."},                       [nil,"\r\n."]],
      [%Q{"a\na","one newline"},           ["a\na", 'one newline']],
      [%Q{"a\n\na","two newlines"},        ["a\n\na", 'two newlines']],
      [%Q{"a\r\na","one CRLF"},            ["a\r\na", 'one CRLF']],
      [%Q{"a\r\n\r\na","two CRLFs"},       ["a\r\n\r\na", 'two CRLFs']],
      [%Q{with blank,"start\n\nfinish"\n}, ['with blank', "start\n\nfinish"]],
    ].each do |edge_case|
      assert_equal(edge_case.last, FasterCSV.parse_line(edge_case.first))
    end
  end

  def test_non_regex_edge_cases
    # An early version of the non-regex parser fails this test
    [["foo,\"foo,bar,baz,foo\",\"foo\"", ["foo", "foo,bar,baz,foo", "foo"]]].each do |edge_case|
      assert_equal(edge_case.last, FasterCSV.parse_line(edge_case.first))
    end

    assert_raise(FasterCSV::MalformedCSVError) do
      FasterCSV.parse_line("1,\"23\"4\"5\", 6")
    end
  end
  
  def test_malformed_csv
    assert_raise(FasterCSV::MalformedCSVError) do
      FasterCSV.parse_line("1,2\r,3", :row_sep => "\n")
    end
    
    bad_data = <<-END_DATA.gsub(/^ +/, "")
    line,1,abc
    line,2,"def\nghi"
    
    line,4,some\rjunk
    line,5,jkl
    END_DATA
    lines = bad_data.to_a
    assert_equal(6, lines.size)
    assert_match(/\Aline,4/, lines.find { |l| l =~ /some\rjunk/ })
    
    csv = FasterCSV.new(bad_data)
    begin
      loop do
        assert_not_nil(csv.shift)
        assert_send([csv.lineno, :<, 4])
      end
    rescue FasterCSV::MalformedCSVError
      assert_equal( "Unquoted fields do not allow \\r or \\n (line 4).",
                    $!.message )
    end

    assert_raise(FasterCSV::MalformedCSVError) do 
      FasterCSV.parse_line('1,2,"3...')
    end
    
    bad_data = <<-END_DATA.gsub(/^ +/, "")
    line,1,abc
    line,2,"def\nghi"
    
    line,4,8'10"
    line,5,jkl
    END_DATA
    lines = bad_data.to_a
    assert_equal(6, lines.size)
    assert_match(/\Aline,4/, lines.find { |l| l =~ /8'10"/ })
    
    csv = FasterCSV.new(bad_data)
    begin
      loop do
        assert_not_nil(csv.shift)
        assert_send([csv.lineno, :<, 4])
      end
    rescue FasterCSV::MalformedCSVError
      assert_equal("Illegal quoting on line 4.", $!.message)
    end
  end
end

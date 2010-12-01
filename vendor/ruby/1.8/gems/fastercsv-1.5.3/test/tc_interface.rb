#!/usr/local/bin/ruby -w

# tc_interface.rb
#
#  Created by James Edward Gray II on 2005-11-14.
#  Copyright 2005 Gray Productions. All rights reserved.

require "test/unit"

require "faster_csv"

class TestFasterCSVInterface < Test::Unit::TestCase
  def setup
    @path = File.join(File.dirname(__FILE__), "temp_test_data.csv")
    
    File.open(@path, "w") do |file|
      file << "1\t2\t3\r\n"
      file << "4\t5\r\n"
    end

    @expected = [%w{1 2 3}, %w{4 5}]
  end
  
  def teardown
    File.unlink(@path)
  end
  
  ### Test Read Interface ###
  
  def test_foreach
    FasterCSV.foreach(@path, :col_sep => "\t", :row_sep => "\r\n") do |row|
      assert_equal(@expected.shift, row)
    end
  end
  
  def test_open_and_close
    csv = FasterCSV.open(@path, "r+", :col_sep => "\t", :row_sep => "\r\n")
    assert_not_nil(csv)
    assert_instance_of(FasterCSV, csv)
    assert_equal(false, csv.closed?)
    csv.close
    assert(csv.closed?)
    
    ret = FasterCSV.open(@path) do |csv|
      assert_instance_of(FasterCSV, csv)
      "Return value."
    end
    assert(csv.closed?)
    assert_equal("Return value.", ret)
  end
  
  def test_parse
    data = File.read(@path)
    assert_equal( @expected,
                  FasterCSV.parse(data, :col_sep => "\t", :row_sep => "\r\n") )

    FasterCSV.parse(data, :col_sep => "\t", :row_sep => "\r\n") do |row|
      assert_equal(@expected.shift, row)
    end
  end
  
  def test_parse_line
    row = FasterCSV.parse_line("1;2;3", :col_sep => ";")
    assert_not_nil(row)
    assert_instance_of(Array, row)
    assert_equal(%w{1 2 3}, row)
    
    # shortcut interface
    row = "1;2;3".parse_csv(:col_sep => ";")
    assert_not_nil(row)
    assert_instance_of(Array, row)
    assert_equal(%w{1 2 3}, row)
  end
  
  def test_parse_line_with_empty_lines
    assert_equal(nil,       FasterCSV.parse_line(""))  # to signal eof
    assert_equal(Array.new, FasterCSV.parse_line("\n1,2,3"))
  end
  
  def test_read_and_readlines
    assert_equal( @expected,
                  FasterCSV.read(@path, :col_sep => "\t", :row_sep => "\r\n") )
    assert_equal( @expected,
                  FasterCSV.readlines( @path,
                                       :col_sep => "\t", :row_sep => "\r\n") )
    
    
    data = FasterCSV.open(@path, :col_sep => "\t", :row_sep => "\r\n") do |csv|
      csv.read
    end
    assert_equal(@expected, data)
    data = FasterCSV.open(@path, :col_sep => "\t", :row_sep => "\r\n") do |csv|
      csv.readlines
    end
    assert_equal(@expected, data)
  end
  
  def test_table
    table = FasterCSV.table(@path, :col_sep => "\t", :row_sep => "\r\n")
    assert_instance_of(FasterCSV::Table, table)
    assert_equal([[:"1", :"2", :"3"], [4, 5, nil]], table.to_a)
  end
  
  def test_shift  # aliased as gets() and readline()
    FasterCSV.open(@path, "r+", :col_sep => "\t", :row_sep => "\r\n") do |csv|
      assert_equal(@expected.shift, csv.shift)
      assert_equal(@expected.shift, csv.shift)
      assert_equal(nil, csv.shift)
    end
  end

  def test_long_line # ruby's regex parser may have problems with long rows
    File.unlink(@path)

    long_field_length = 2800
    File.open(@path, "w") do |file|
      file << "1\t2\t#{'3' * long_field_length}\r\n"
    end
    @expected = [%w{1 2} + ['3' * long_field_length]]
    test_shift
  end
  
  ### Test Write Interface ###

  def test_generate
    str = FasterCSV.generate do |csv|  # default empty String
      assert_instance_of(FasterCSV, csv)
      assert_equal(csv, csv << [1, 2, 3])
      assert_equal(csv, csv << [4, nil, 5])
    end
    assert_not_nil(str)
    assert_instance_of(String, str)
    assert_equal("1,2,3\n4,,5\n", str)

    FasterCSV.generate(str) do |csv|   # appending to a String
      assert_equal(csv, csv << ["last", %Q{"row"}])
    end
    assert_equal(%Q{1,2,3\n4,,5\nlast,"""row"""\n}, str)
  end
  
  def test_generate_line
    line = FasterCSV.generate_line(%w{1 2 3}, :col_sep => ";")
    assert_not_nil(line)
    assert_instance_of(String, line)
    assert_equal("1;2;3\n", line)
    
    # shortcut interface
    line = %w{1 2 3}.to_csv(:col_sep => ";")
    assert_not_nil(line)
    assert_instance_of(String, line)
    assert_equal("1;2;3\n", line)
  end

  def test_write_header_detection
    File.unlink(@path)

    headers = %w{a b c}
    FasterCSV.open(@path, "w", :headers => true) do |csv|
      csv << headers
      csv << %w{1 2 3}
      assert_equal(headers, csv.instance_variable_get(:@headers))
    end
  end

  def test_write_lineno
    File.unlink(@path)

    FasterCSV.open(@path, "w") do |csv|
      lines = 20
      lines.times { csv << %w{a b c} }
      assert_equal(lines, csv.lineno)
    end
  end

  def test_write_hash
    File.unlink(@path)

    lines = [{:a => 1, :b => 2, :c => 3}, {:a => 4, :b => 5, :c => 6}]
    FasterCSV.open( @path, "w", :headers           => true,
                                :header_converters => :symbol ) do |csv|
      csv << lines.first.keys
      lines.each { |line| csv << line }
    end
    FasterCSV.open( @path, "r", :headers           => true,
                                :converters        => :all,
                                :header_converters => :symbol ) do |csv|
      csv.each { |line| assert_equal(lines.shift, line.to_hash) }
    end
  end

  def test_write_hash_with_headers_array
    File.unlink(@path)

    lines = [{:a => 1, :b => 2, :c => 3}, {:a => 4, :b => 5, :c => 6}]
    FasterCSV.open(@path, "w", :headers => [:b, :a, :c]) do |csv|
      lines.each { |line| csv << line }
    end

    # test writing fields in the correct order
    File.open(@path, "r") do |f|
      assert_equal("2,1,3", f.gets.strip)
      assert_equal("5,4,6", f.gets.strip)
    end

    # test reading CSV with headers
    FasterCSV.open( @path, "r", :headers    => [:b, :a, :c],
                                :converters => :all ) do |csv|
      csv.each { |line| assert_equal(lines.shift, line.to_hash) }
    end
  end

  def test_write_hash_with_headers_string
    File.unlink(@path)

    lines = [{"a" => 1, "b" => 2, "c" => 3}, {"a" => 4, "b" => 5, "c" => 6}]
    FasterCSV.open( @path, "w", :headers => "b|a|c",
                                :col_sep => "|" ) do |csv|
      lines.each { |line| csv << line }
    end

    # test writing fields in the correct order
    File.open(@path, "r") do |f|
      assert_equal("2|1|3", f.gets.strip)
      assert_equal("5|4|6", f.gets.strip)
    end

    # test reading CSV with headers
    FasterCSV.open( @path, "r", :headers    => "b|a|c",
                                :col_sep    => "|",
                                :converters => :all ) do |csv|
      csv.each { |line| assert_equal(lines.shift, line.to_hash) }
    end
  end
  
  def test_write_headers
    File.unlink(@path)

    lines = [{"a" => 1, "b" => 2, "c" => 3}, {"a" => 4, "b" => 5, "c" => 6}]
    FasterCSV.open( @path, "w", :headers       => "b|a|c",
                                :write_headers => true,
                                :col_sep       => "|" ) do |csv|
      lines.each { |line| csv << line }
    end

    # test writing fields in the correct order
    File.open(@path, "r") do |f|
      assert_equal("b|a|c", f.gets.strip)
      assert_equal("2|1|3", f.gets.strip)
      assert_equal("5|4|6", f.gets.strip)
    end

    # test reading CSV with headers
    FasterCSV.open( @path, "r", :headers    => true,
                                :col_sep    => "|",
                                :converters => :all ) do |csv|
      csv.each { |line| assert_equal(lines.shift, line.to_hash) }
    end
  end
  
  def test_append  # aliased add_row() and puts()
    File.unlink(@path)
    
    FasterCSV.open(@path, "w", :col_sep => "\t", :row_sep => "\r\n") do |csv|
      @expected.each { |row| csv << row }
    end

    test_shift

    # same thing using FasterCSV::Row objects
    File.unlink(@path)
    
    FasterCSV.open(@path, "w", :col_sep => "\t", :row_sep => "\r\n") do |csv|
      @expected.each { |row| csv << FasterCSV::Row.new(Array.new, row) }
    end

    test_shift
  end
  
  ### Test Read and Write Interface ###
  
  def test_filter
    assert_respond_to(FasterCSV, :filter)
    
    expected = [[1, 2, 3], [4, 5]]
    FasterCSV.filter( "1;2;3\n4;5\n", (result = String.new),
                      :in_col_sep => ";", :out_col_sep => ",",
                      :converters => :all ) do |row|
      assert_equal(row, expected.shift)
      row.map! { |n| n * 2 }
      row << "Added\r"
    end
    assert_equal("2,4,6,\"Added\r\"\n8,10,\"Added\r\"\n", result)
  end
  
  def test_instance
    csv = String.new
    
    first = nil
    assert_nothing_raised(Exception) do 
      first =  FasterCSV.instance(csv, :col_sep => ";")
      first << %w{a b c}
    end
    
    assert_equal("a;b;c\n", csv)
    
    second = nil
    assert_nothing_raised(Exception) do 
      second =  FasterCSV.instance(csv, :col_sep => ";")
      second << [1, 2, 3]
    end
    
    assert_equal(first.object_id, second.object_id)
    assert_equal("a;b;c\n1;2;3\n", csv)
    
    # shortcuts
    assert_equal(STDOUT, FasterCSV.instance.instance_eval { @io })
    assert_equal(STDOUT, FasterCSV { |csv| csv.instance_eval { @io } })
    assert_equal(STDOUT, FCSV.instance.instance_eval { @io })
    assert_equal(STDOUT, FCSV { |csv| csv.instance_eval { @io } })
  end
  
  ### Test Alternate Interface ###
  
  def test_csv_interface
    require "csv"
    data      = ["Number", 42, "Tricky Field", 'This has embedded "quotes"!']
    data_file = File.join(File.dirname(__FILE__), "temp_csv_data.csv")
    CSV.open(data_file, "w") { |f| 10.times { f << data } }
    csv   = CSV.generate_line(data)
    tests = { :foreach       => Array.new,
              :generate_line => csv,
              :open          => Array.new,
              :parse         => CSV.parse(csv),
              :parse_w_block => Array.new,
              :parse_line    => CSV.parse_line(csv),
              :readlines     => CSV.readlines(data_file) }
    CSV.foreach(data_file) { |row| tests[:foreach] << row }
    CSV.open(data_file, "r") { |row| tests[:open] << row }
    CSV.parse(([csv] * 3).join("\n")) { |row| tests[:parse_w_block] << row }
    Object.send(:remove_const, :CSV)
    
    assert_nothing_raised(Exception) do 
      FasterCSV.build_csv_interface
    end
    
    %w{ foreach
        generate_line
        open
        parse
        parse_line
        readlines }.each do |meth|
      assert_respond_to(::CSV, meth)
    end
    
    faster_csv = Array.new
    CSV.foreach(data_file) { |row| faster_csv << row }
    assert_equal(tests[:foreach], faster_csv)
    assert_equal(tests[:generate_line], CSV.generate_line(data))
    faster_csv.clear
    CSV.open(data_file, "r") { |row| faster_csv << row }
    assert_equal(tests[:open], faster_csv)
    comp_file = data_file.sub("_csv_data", "_faster_csv_data")
    CSV.open(comp_file, "w") { |f| 10.times { f << data } }
    assert_equal(File.read(data_file), File.read(comp_file))
    assert_equal(tests[:parse], CSV.parse(csv))
    faster_csv.clear
    CSV.parse(([csv] * 3).join("\n")) { |row| faster_csv << row }
    assert_equal(tests[:parse_w_block], faster_csv)
    assert_equal(tests[:parse_line], CSV.parse_line(csv))
    assert_equal(tests[:readlines], CSV.readlines(data_file))
    
    Object.send(:remove_const, :CSV)
    load "csv.rb"
    [data_file, comp_file].each { |file| File.unlink(file) }
  end
end

#!/usr/local/bin/ruby -w

# = faster_csv.rb -- Faster CSV Reading and Writing
#
#  Created by James Edward Gray II on 2005-10-31.
#  Copyright 2005 Gray Productions. All rights reserved.
# 
# See FasterCSV for documentation.

if RUBY_VERSION >= "1.9"
  abort <<-VERSION_WARNING.gsub(/^\s+/, "")
  Please switch to Ruby 1.9's standard CSV library.  It's FasterCSV plus
  support for Ruby 1.9's m17n encoding engine.
  VERSION_WARNING
end

require "forwardable"
require "English"
require "enumerator"
require "date"
require "stringio"

# 
# This class provides a complete interface to CSV files and data.  It offers
# tools to enable you to read and write to and from Strings or IO objects, as
# needed.
# 
# == Reading
# 
# === From a File
# 
# ==== A Line at a Time
# 
#   FasterCSV.foreach("path/to/file.csv") do |row|
#     # use row here...
#   end
# 
# ==== All at Once
# 
#   arr_of_arrs = FasterCSV.read("path/to/file.csv")
# 
# === From a String
# 
# ==== A Line at a Time
# 
#   FasterCSV.parse("CSV,data,String") do |row|
#     # use row here...
#   end
# 
# ==== All at Once
# 
#   arr_of_arrs = FasterCSV.parse("CSV,data,String")
# 
# == Writing
# 
# === To a File
# 
#   FasterCSV.open("path/to/file.csv", "w") do |csv|
#     csv << ["row", "of", "CSV", "data"]
#     csv << ["another", "row"]
#     # ...
#   end
# 
# === To a String
# 
#   csv_string = FasterCSV.generate do |csv|
#     csv << ["row", "of", "CSV", "data"]
#     csv << ["another", "row"]
#     # ...
#   end
# 
# == Convert a Single Line
# 
#   csv_string = ["CSV", "data"].to_csv   # to CSV
#   csv_array  = "CSV,String".parse_csv   # from CSV
# 
# == Shortcut Interface
# 
#   FCSV             { |csv_out| csv_out << %w{my data here} }  # to $stdout
#   FCSV(csv = "")   { |csv_str| csv_str << %w{my data here} }  # to a String
#   FCSV($stderr)    { |csv_err| csv_err << %w{my data here} }  # to $stderr
# 
class FasterCSV
  # The version of the installed library.
  VERSION = "1.5.3".freeze
  
  # 
  # A FasterCSV::Row is part Array and part Hash.  It retains an order for the
  # fields and allows duplicates just as an Array would, but also allows you to
  # access fields by name just as you could if they were in a Hash.
  # 
  # All rows returned by FasterCSV will be constructed from this class, if
  # header row processing is activated.
  # 
  class Row
    # 
    # Construct a new FasterCSV::Row from +headers+ and +fields+, which are
    # expected to be Arrays.  If one Array is shorter than the other, it will be
    # padded with +nil+ objects.
    # 
    # The optional +header_row+ parameter can be set to +true+ to indicate, via
    # FasterCSV::Row.header_row?() and FasterCSV::Row.field_row?(), that this is
    # a header row.  Otherwise, the row is assumes to be a field row.
    # 
    # A FasterCSV::Row object supports the following Array methods through
    # delegation:
    # 
    # * empty?()
    # * length()
    # * size()
    # 
    def initialize(headers, fields, header_row = false)
      @header_row = header_row
      
      # handle extra headers or fields
      @row = if headers.size > fields.size
        headers.zip(fields)
      else
        fields.zip(headers).map { |pair| pair.reverse }
      end
    end
    
    # Internal data format used to compare equality.
    attr_reader :row
    protected   :row

    ### Array Delegation ###

    extend Forwardable
    def_delegators :@row, :empty?, :length, :size
    
    # Returns +true+ if this is a header row.
    def header_row?
      @header_row
    end
    
    # Returns +true+ if this is a field row.
    def field_row?
      not header_row?
    end
    
    # Returns the headers of this row.
    def headers
      @row.map { |pair| pair.first }
    end
    
    # 
    # :call-seq:
    #   field( header )
    #   field( header, offset )
    #   field( index )
    # 
    # This method will fetch the field value by +header+ or +index+.  If a field
    # is not found, +nil+ is returned.
    # 
    # When provided, +offset+ ensures that a header match occurrs on or later
    # than the +offset+ index.  You can use this to find duplicate headers, 
    # without resorting to hard-coding exact indices.
    # 
    def field(header_or_index, minimum_index = 0)
      # locate the pair
      finder = header_or_index.is_a?(Integer) ? :[] : :assoc
      pair   = @row[minimum_index..-1].send(finder, header_or_index)

      # return the field if we have a pair
      pair.nil? ? nil : pair.last
    end
    alias_method :[], :field
    
    # 
    # :call-seq:
    #   []=( header, value )
    #   []=( header, offset, value )
    #   []=( index, value )
    # 
    # Looks up the field by the semantics described in FasterCSV::Row.field()
    # and assigns the +value+.
    # 
    # Assigning past the end of the row with an index will set all pairs between
    # to <tt>[nil, nil]</tt>.  Assigning to an unused header appends the new
    # pair.
    # 
    def []=(*args)
      value = args.pop
      
      if args.first.is_a? Integer
        if @row[args.first].nil?  # extending past the end with index
          @row[args.first] = [nil, value]
          @row.map! { |pair| pair.nil? ? [nil, nil] : pair }
        else                      # normal index assignment
          @row[args.first][1] = value
        end
      else
        index = index(*args)
        if index.nil?             # appending a field
          self << [args.first, value]
        else                      # normal header assignment
          @row[index][1] = value
        end
      end
    end
    
    # 
    # :call-seq:
    #   <<( field )
    #   <<( header_and_field_array )
    #   <<( header_and_field_hash )
    # 
    # If a two-element Array is provided, it is assumed to be a header and field
    # and the pair is appended.  A Hash works the same way with the key being
    # the header and the value being the field.  Anything else is assumed to be
    # a lone field which is appended with a +nil+ header.
    # 
    # This method returns the row for chaining.
    # 
    def <<(arg)
      if arg.is_a?(Array) and arg.size == 2  # appending a header and name
        @row << arg
      elsif arg.is_a?(Hash)                  # append header and name pairs
        arg.each { |pair| @row << pair }
      else                                   # append field value
        @row << [nil, arg]
      end
      
      self  # for chaining
    end
    
    # 
    # A shortcut for appending multiple fields.  Equivalent to:
    # 
    #   args.each { |arg| faster_csv_row << arg }
    # 
    # This method returns the row for chaining.
    # 
    def push(*args)
      args.each { |arg| self << arg }
      
      self  # for chaining
    end
    
    # 
    # :call-seq:
    #   delete( header )
    #   delete( header, offset )
    #   delete( index )
    # 
    # Used to remove a pair from the row by +header+ or +index+.  The pair is
    # located as described in FasterCSV::Row.field().  The deleted pair is 
    # returned, or +nil+ if a pair could not be found.
    # 
    def delete(header_or_index, minimum_index = 0)
      if header_or_index.is_a? Integer                 # by index
        @row.delete_at(header_or_index)
      elsif i = index(header_or_index, minimum_index)  # by header
        @row.delete_at(i)
      else
        [ ]
      end
    end
    
    # 
    # The provided +block+ is passed a header and field for each pair in the row
    # and expected to return +true+ or +false+, depending on whether the pair
    # should be deleted.
    # 
    # This method returns the row for chaining.
    # 
    def delete_if(&block)
      @row.delete_if(&block)
      
      self  # for chaining
    end
    
    # 
    # This method accepts any number of arguments which can be headers, indices,
    # Ranges of either, or two-element Arrays containing a header and offset.  
    # Each argument will be replaced with a field lookup as described in
    # FasterCSV::Row.field().
    # 
    # If called with no arguments, all fields are returned.
    # 
    def fields(*headers_and_or_indices)
      if headers_and_or_indices.empty?  # return all fields--no arguments
        @row.map { |pair| pair.last }
      else                              # or work like values_at()
        headers_and_or_indices.inject(Array.new) do |all, h_or_i|
          all + if h_or_i.is_a? Range
            index_begin = h_or_i.begin.is_a?(Integer) ? h_or_i.begin :
                                                        index(h_or_i.begin)
            index_end   = h_or_i.end.is_a?(Integer)   ? h_or_i.end :
                                                        index(h_or_i.end)
            new_range   = h_or_i.exclude_end? ? (index_begin...index_end) :
                                                (index_begin..index_end)
            fields.values_at(new_range)
          else
            [field(*Array(h_or_i))]
          end
        end
      end
    end
    alias_method :values_at, :fields
    
    # 
    # :call-seq:
    #   index( header )
    #   index( header, offset )
    # 
    # This method will return the index of a field with the provided +header+.
    # The +offset+ can be used to locate duplicate header names, as described in
    # FasterCSV::Row.field().
    # 
    def index(header, minimum_index = 0)
      # find the pair
      index = headers[minimum_index..-1].index(header)
      # return the index at the right offset, if we found one
      index.nil? ? nil : index + minimum_index
    end
    
    # Returns +true+ if +name+ is a header for this row, and +false+ otherwise.
    def header?(name)
      headers.include? name
    end
    alias_method :include?, :header?
    
    # 
    # Returns +true+ if +data+ matches a field in this row, and +false+
    # otherwise.
    # 
    def field?(data)
      fields.include? data
    end

    include Enumerable
    
    # 
    # Yields each pair of the row as header and field tuples (much like
    # iterating over a Hash).
    # 
    # Support for Enumerable.
    # 
    # This method returns the row for chaining.
    # 
    def each(&block)
      @row.each(&block)
      
      self  # for chaining
    end
    
    # 
    # Returns +true+ if this row contains the same headers and fields in the 
    # same order as +other+.
    # 
    def ==(other)
      @row == other.row
    end
    
    # 
    # Collapses the row into a simple Hash.  Be warning that this discards field
    # order and clobbers duplicate fields.
    # 
    def to_hash
      # flatten just one level of the internal Array
      Hash[*@row.inject(Array.new) { |ary, pair| ary.push(*pair) }]
    end
    
    # 
    # Returns the row as a CSV String.  Headers are not used.  Equivalent to:
    # 
    #   faster_csv_row.fields.to_csv( options )
    # 
    def to_csv(options = Hash.new)
      fields.to_csv(options)
    end
    alias_method :to_s, :to_csv
    
    # A summary of fields, by header.
    def inspect
      str = "#<#{self.class}"
      each do |header, field|
        str << " #{header.is_a?(Symbol) ? header.to_s : header.inspect}:" <<
               field.inspect
      end
      str << ">"
    end
  end
  
  # 
  # A FasterCSV::Table is a two-dimensional data structure for representing CSV
  # documents.  Tables allow you to work with the data by row or column, 
  # manipulate the data, and even convert the results back to CSV, if needed.
  # 
  # All tables returned by FasterCSV will be constructed from this class, if
  # header row processing is activated.
  # 
  class Table
    # 
    # Construct a new FasterCSV::Table from +array_of_rows+, which are expected
    # to be FasterCSV::Row objects.  All rows are assumed to have the same 
    # headers.
    # 
    # A FasterCSV::Table object supports the following Array methods through
    # delegation:
    # 
    # * empty?()
    # * length()
    # * size()
    # 
    def initialize(array_of_rows)
      @table = array_of_rows
      @mode  = :col_or_row
    end
    
    # The current access mode for indexing and iteration.
    attr_reader :mode
    
    # Internal data format used to compare equality.
    attr_reader :table
    protected   :table

    ### Array Delegation ###

    extend Forwardable
    def_delegators :@table, :empty?, :length, :size
    
    # 
    # Returns a duplicate table object, in column mode.  This is handy for 
    # chaining in a single call without changing the table mode, but be aware 
    # that this method can consume a fair amount of memory for bigger data sets.
    # 
    # This method returns the duplicate table for chaining.  Don't chain
    # destructive methods (like []=()) this way though, since you are working
    # with a duplicate.
    # 
    def by_col
      self.class.new(@table.dup).by_col!
    end
    
    # 
    # Switches the mode of this table to column mode.  All calls to indexing and
    # iteration methods will work with columns until the mode is changed again.
    # 
    # This method returns the table and is safe to chain.
    # 
    def by_col!
      @mode = :col
      
      self
    end
    
    # 
    # Returns a duplicate table object, in mixed mode.  This is handy for 
    # chaining in a single call without changing the table mode, but be aware 
    # that this method can consume a fair amount of memory for bigger data sets.
    # 
    # This method returns the duplicate table for chaining.  Don't chain
    # destructive methods (like []=()) this way though, since you are working
    # with a duplicate.
    # 
    def by_col_or_row
      self.class.new(@table.dup).by_col_or_row!
    end
    
    # 
    # Switches the mode of this table to mixed mode.  All calls to indexing and
    # iteration methods will use the default intelligent indexing system until
    # the mode is changed again.  In mixed mode an index is assumed to be a row
    # reference while anything else is assumed to be column access by headers.
    # 
    # This method returns the table and is safe to chain.
    # 
    def by_col_or_row!
      @mode = :col_or_row
      
      self
    end
    
    # 
    # Returns a duplicate table object, in row mode.  This is handy for chaining
    # in a single call without changing the table mode, but be aware that this
    # method can consume a fair amount of memory for bigger data sets.
    # 
    # This method returns the duplicate table for chaining.  Don't chain
    # destructive methods (like []=()) this way though, since you are working
    # with a duplicate.
    # 
    def by_row
      self.class.new(@table.dup).by_row!
    end
    
    # 
    # Switches the mode of this table to row mode.  All calls to indexing and
    # iteration methods will work with rows until the mode is changed again.
    # 
    # This method returns the table and is safe to chain.
    # 
    def by_row!
      @mode = :row
      
      self
    end
    
    # 
    # Returns the headers for the first row of this table (assumed to match all
    # other rows).  An empty Array is returned for empty tables.
    # 
    def headers
      if @table.empty?
        Array.new
      else
        @table.first.headers
      end
    end
    
    # 
    # In the default mixed mode, this method returns rows for index access and
    # columns for header access.  You can force the index association by first
    # calling by_col!() or by_row!().
    # 
    # Columns are returned as an Array of values.  Altering that Array has no
    # effect on the table.
    # 
    def [](index_or_header)
      if @mode == :row or  # by index
         (@mode == :col_or_row and index_or_header.is_a? Integer)
        @table[index_or_header]
      else                 # by header
        @table.map { |row| row[index_or_header] }
      end
    end
    
    # 
    # In the default mixed mode, this method assigns rows for index access and
    # columns for header access.  You can force the index association by first
    # calling by_col!() or by_row!().
    # 
    # Rows may be set to an Array of values (which will inherit the table's
    # headers()) or a FasterCSV::Row.
    # 
    # Columns may be set to a single value, which is copied to each row of the 
    # column, or an Array of values.  Arrays of values are assigned to rows top
    # to bottom in row major order.  Excess values are ignored and if the Array
    # does not have a value for each row the extra rows will receive a +nil+.
    # 
    # Assigning to an existing column or row clobbers the data.  Assigning to
    # new columns creates them at the right end of the table.
    # 
    def []=(index_or_header, value)
      if @mode == :row or  # by index
         (@mode == :col_or_row and index_or_header.is_a? Integer)
        if value.is_a? Array
          @table[index_or_header] = Row.new(headers, value)
        else
          @table[index_or_header] = value
        end
      else                 # set column
        if value.is_a? Array  # multiple values
          @table.each_with_index do |row, i|
            if row.header_row?
              row[index_or_header] = index_or_header
            else
              row[index_or_header] = value[i]
            end
          end
        else                  # repeated value
          @table.each do |row|
            if row.header_row?
              row[index_or_header] = index_or_header
            else
              row[index_or_header] = value
            end
          end
        end
      end
    end
    
    # 
    # The mixed mode default is to treat a list of indices as row access,
    # returning the rows indicated.  Anything else is considered columnar
    # access.  For columnar access, the return set has an Array for each row
    # with the values indicated by the headers in each Array.  You can force
    # column or row mode using by_col!() or by_row!().
    # 
    # You cannot mix column and row access.
    # 
    def values_at(*indices_or_headers)
      if @mode == :row or  # by indices
         ( @mode == :col_or_row and indices_or_headers.all? do |index|
                                      index.is_a?(Integer)         or
                                      ( index.is_a?(Range)         and
                                        index.first.is_a?(Integer) and
                                        index.last.is_a?(Integer) )
                                    end )
        @table.values_at(*indices_or_headers)
      else                 # by headers
        @table.map { |row| row.values_at(*indices_or_headers) }
      end
    end

    # 
    # Adds a new row to the bottom end of this table.  You can provide an Array,
    # which will be converted to a FasterCSV::Row (inheriting the table's
    # headers()), or a FasterCSV::Row.
    # 
    # This method returns the table for chaining.
    # 
    def <<(row_or_array)
      if row_or_array.is_a? Array  # append Array
        @table << Row.new(headers, row_or_array)
      else                         # append Row
        @table << row_or_array
      end
      
      self  # for chaining
    end
    
    # 
    # A shortcut for appending multiple rows.  Equivalent to:
    # 
    #   rows.each { |row| self << row }
    # 
    # This method returns the table for chaining.
    # 
    def push(*rows)
      rows.each { |row| self << row }
      
      self  # for chaining
    end

    # 
    # Removes and returns the indicated column or row.  In the default mixed
    # mode indices refer to rows and everything else is assumed to be a column
    # header.  Use by_col!() or by_row!() to force the lookup.
    # 
    def delete(index_or_header)
      if @mode == :row or  # by index
         (@mode == :col_or_row and index_or_header.is_a? Integer)
        @table.delete_at(index_or_header)
      else                 # by header
        @table.map { |row| row.delete(index_or_header).last }
      end
    end
    
    # 
    # Removes any column or row for which the block returns +true+.  In the
    # default mixed mode or row mode, iteration is the standard row major
    # walking of rows.  In column mode, interation will +yield+ two element
    # tuples containing the column name and an Array of values for that column.
    # 
    # This method returns the table for chaining.
    # 
    def delete_if(&block)
      if @mode == :row or @mode == :col_or_row  # by index
        @table.delete_if(&block)
      else                                      # by header
        to_delete = Array.new
        headers.each_with_index do |header, i|
          to_delete << header if block[[header, self[header]]]
        end
        to_delete.map { |header| delete(header) }
      end
      
      self  # for chaining
    end
    
    include Enumerable
    
    # 
    # In the default mixed mode or row mode, iteration is the standard row major
    # walking of rows.  In column mode, interation will +yield+ two element
    # tuples containing the column name and an Array of values for that column.
    # 
    # This method returns the table for chaining.
    # 
    def each(&block)
      if @mode == :col
        headers.each { |header| block[[header, self[header]]] }
      else
        @table.each(&block)
      end
      
      self  # for chaining
    end
    
    # Returns +true+ if all rows of this table ==() +other+'s rows.
    def ==(other)
      @table == other.table
    end
    
    # 
    # Returns the table as an Array of Arrays.  Headers will be the first row,
    # then all of the field rows will follow.
    # 
    def to_a
      @table.inject([headers]) do |array, row|
        if row.header_row?
          array
        else
          array + [row.fields]
        end
      end
    end
    
    # 
    # Returns the table as a complete CSV String.  Headers will be listed first,
    # then all of the field rows.
    # 
    # This method assumes you want the Table.headers(), unless you explicitly
    # pass <tt>:write_headers => false</tt>.
    # 
    def to_csv(options = Hash.new)
      wh = options.fetch(:write_headers, true)
      @table.inject(wh ? [headers.to_csv(options)] : [ ]) do |rows, row|
        if row.header_row?
          rows
        else
          rows + [row.fields.to_csv(options)]
        end
      end.join
    end
    alias_method :to_s, :to_csv
    
    def inspect
      "#<#{self.class} mode:#{@mode} row_count:#{to_a.size}>"
    end
  end

  # The error thrown when the parser encounters illegal CSV formatting.
  class MalformedCSVError < RuntimeError; end
  
  # 
  # A FieldInfo Struct contains details about a field's position in the data
  # source it was read from.  FasterCSV will pass this Struct to some blocks
  # that make decisions based on field structure.  See 
  # FasterCSV.convert_fields() for an example.
  # 
  # <b><tt>index</tt></b>::  The zero-based index of the field in its row.
  # <b><tt>line</tt></b>::   The line of the data source this row is from.
  # <b><tt>header</tt></b>:: The header for the column, when available.
  # 
  FieldInfo = Struct.new(:index, :line, :header)
  
  # A Regexp used to find and convert some common Date formats.
  DateMatcher     = / \A(?: (\w+,?\s+)?\w+\s+\d{1,2},?\s+\d{2,4} |
                            \d{4}-\d{2}-\d{2} )\z /x
  # A Regexp used to find and convert some common DateTime formats.
  DateTimeMatcher =
    / \A(?: (\w+,?\s+)?\w+\s+\d{1,2}\s+\d{1,2}:\d{1,2}:\d{1,2},?\s+\d{2,4} |
            \d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2} )\z /x
  # 
  # This Hash holds the built-in converters of FasterCSV that can be accessed by
  # name.  You can select Converters with FasterCSV.convert() or through the
  # +options+ Hash passed to FasterCSV::new().
  # 
  # <b><tt>:integer</tt></b>::    Converts any field Integer() accepts.
  # <b><tt>:float</tt></b>::      Converts any field Float() accepts.
  # <b><tt>:numeric</tt></b>::    A combination of <tt>:integer</tt> 
  #                               and <tt>:float</tt>.
  # <b><tt>:date</tt></b>::       Converts any field Date::parse() accepts.
  # <b><tt>:date_time</tt></b>::  Converts any field DateTime::parse() accepts.
  # <b><tt>:all</tt></b>::        All built-in converters.  A combination of 
  #                               <tt>:date_time</tt> and <tt>:numeric</tt>.
  # 
  # This Hash is intetionally left unfrozen and users should feel free to add
  # values to it that can be accessed by all FasterCSV objects.
  # 
  # To add a combo field, the value should be an Array of names.  Combo fields
  # can be nested with other combo fields.
  # 
  Converters  = { :integer   => lambda { |f| Integer(f)        rescue f },
                  :float     => lambda { |f| Float(f)          rescue f },
                  :numeric   => [:integer, :float],
                  :date      => lambda { |f|
                    f =~ DateMatcher ? (Date.parse(f) rescue f) : f
                  },
                  :date_time => lambda { |f|
                    f =~ DateTimeMatcher ? (DateTime.parse(f) rescue f) : f
                  },
                  :all       => [:date_time, :numeric] }

  # 
  # This Hash holds the built-in header converters of FasterCSV that can be
  # accessed by name.  You can select HeaderConverters with
  # FasterCSV.header_convert() or through the +options+ Hash passed to
  # FasterCSV::new().
  # 
  # <b><tt>:downcase</tt></b>::  Calls downcase() on the header String.
  # <b><tt>:symbol</tt></b>::    The header String is downcased, spaces are
  #                              replaced with underscores, non-word characters
  #                              are dropped, and finally to_sym() is called.
  # 
  # This Hash is intetionally left unfrozen and users should feel free to add
  # values to it that can be accessed by all FasterCSV objects.
  # 
  # To add a combo field, the value should be an Array of names.  Combo fields
  # can be nested with other combo fields.
  # 
  HeaderConverters = {
    :downcase => lambda { |h| h.downcase },
    :symbol   => lambda { |h|
      h.downcase.tr(" ", "_").delete("^a-z0-9_").to_sym
    }
  }
  
  # 
  # The options used when no overrides are given by calling code.  They are:
  # 
  # <b><tt>:col_sep</tt></b>::            <tt>","</tt>
  # <b><tt>:row_sep</tt></b>::            <tt>:auto</tt>
  # <b><tt>:quote_char</tt></b>::         <tt>'"'</tt>
  # <b><tt>:converters</tt></b>::         +nil+
  # <b><tt>:unconverted_fields</tt></b>:: +nil+
  # <b><tt>:headers</tt></b>::            +false+
  # <b><tt>:return_headers</tt></b>::     +false+
  # <b><tt>:header_converters</tt></b>::  +nil+
  # <b><tt>:skip_blanks</tt></b>::        +false+
  # <b><tt>:force_quotes</tt></b>::       +false+
  # 
  DEFAULT_OPTIONS = { :col_sep            => ",",
                      :row_sep            => :auto,
                      :quote_char         => '"', 
                      :converters         => nil,
                      :unconverted_fields => nil,
                      :headers            => false,
                      :return_headers     => false,
                      :header_converters  => nil,
                      :skip_blanks        => false,
                      :force_quotes       => false }.freeze
  
  # 
  # This method will build a drop-in replacement for many of the standard CSV
  # methods.  It allows you to write code like:
  # 
  #   begin
  #     require "faster_csv"
  #     FasterCSV.build_csv_interface
  #   rescue LoadError
  #     require "csv"
  #   end
  #   # ... use CSV here ...
  # 
  # This is not a complete interface with completely identical behavior.
  # However, it is intended to be close enough that you won't notice the
  # difference in most cases.  CSV methods supported are:
  # 
  # * foreach()
  # * generate_line()
  # * open()
  # * parse()
  # * parse_line()
  # * readlines()
  # 
  # Be warned that this interface is slower than vanilla FasterCSV due to the
  # extra layer of method calls.  Depending on usage, this can slow it down to 
  # near CSV speeds.
  # 
  def self.build_csv_interface
    Object.const_set(:CSV, Class.new).class_eval do
      def self.foreach(path, rs = :auto, &block)  # :nodoc:
        FasterCSV.foreach(path, :row_sep => rs, &block)
      end
      
      def self.generate_line(row, fs = ",", rs = "")  # :nodoc:
        FasterCSV.generate_line(row, :col_sep => fs, :row_sep => rs)
      end
      
      def self.open(path, mode, fs = ",", rs = :auto, &block)  # :nodoc:
        if block and mode.include? "r"
          FasterCSV.open(path, mode, :col_sep => fs, :row_sep => rs) do |csv|
            csv.each(&block)
          end
        else
          FasterCSV.open(path, mode, :col_sep => fs, :row_sep => rs, &block)
        end
      end
      
      def self.parse(str_or_readable, fs = ",", rs = :auto, &block)  # :nodoc:
        FasterCSV.parse(str_or_readable, :col_sep => fs, :row_sep => rs, &block)
      end
      
      def self.parse_line(src, fs = ",", rs = :auto)  # :nodoc:
        FasterCSV.parse_line(src, :col_sep => fs, :row_sep => rs)
      end
      
      def self.readlines(path, rs = :auto)  # :nodoc:
        FasterCSV.readlines(path, :row_sep => rs)
      end
    end
  end
  
  # 
  # This method allows you to serialize an Array of Ruby objects to a String or
  # File of CSV data.  This is not as powerful as Marshal or YAML, but perhaps
  # useful for spreadsheet and database interaction.
  # 
  # Out of the box, this method is intended to work with simple data objects or
  # Structs.  It will serialize a list of instance variables and/or
  # Struct.members().
  # 
  # If you need need more complicated serialization, you can control the process
  # by adding methods to the class to be serialized.
  # 
  # A class method csv_meta() is responsible for returning the first row of the
  # document (as an Array).  This row is considered to be a Hash of the form
  # key_1,value_1,key_2,value_2,...  FasterCSV::load() expects to find a class
  # key with a value of the stringified class name and FasterCSV::dump() will
  # create this, if you do not define this method.  This method is only called
  # on the first object of the Array.
  # 
  # The next method you can provide is an instance method called csv_headers().
  # This method is expected to return the second line of the document (again as
  # an Array), which is to be used to give each column a header.  By default,
  # FasterCSV::load() will set an instance variable if the field header starts
  # with an @ character or call send() passing the header as the method name and
  # the field value as an argument.  This method is only called on the first
  # object of the Array.
  # 
  # Finally, you can provide an instance method called csv_dump(), which will
  # be passed the headers.  This should return an Array of fields that can be
  # serialized for this object.  This method is called once for every object in
  # the Array.
  # 
  # The +io+ parameter can be used to serialize to a File, and +options+ can be
  # anything FasterCSV::new() accepts.
  # 
  def self.dump(ary_of_objs, io = "", options = Hash.new)
    obj_template = ary_of_objs.first
    
    csv = FasterCSV.new(io, options)
    
    # write meta information
    begin
      csv << obj_template.class.csv_meta
    rescue NoMethodError
      csv << [:class, obj_template.class]
    end

    # write headers
    begin
      headers = obj_template.csv_headers
    rescue NoMethodError
      headers = obj_template.instance_variables.sort
      if obj_template.class.ancestors.find { |cls| cls.to_s =~ /\AStruct\b/ }
        headers += obj_template.members.map { |mem| "#{mem}=" }.sort
      end
    end
    csv << headers
    
    # serialize each object
    ary_of_objs.each do |obj|
      begin
        csv << obj.csv_dump(headers)
      rescue NoMethodError
        csv << headers.map do |var|
          if var[0] == ?@
            obj.instance_variable_get(var)
          else
            obj[var[0..-2]]
          end
        end
      end
    end
    
    if io.is_a? String
      csv.string
    else
      csv.close
    end
  end
  
  # 
  # :call-seq:
  #   filter( options = Hash.new ) { |row| ... }
  #   filter( input, options = Hash.new ) { |row| ... }
  #   filter( input, output, options = Hash.new ) { |row| ... }
  # 
  # This method is a convenience for building Unix-like filters for CSV data.
  # Each row is yielded to the provided block which can alter it as needed.  
  # After the block returns, the row is appended to +output+ altered or not.
  # 
  # The +input+ and +output+ arguments can be anything FasterCSV::new() accepts
  # (generally String or IO objects).  If not given, they default to 
  # <tt>ARGF</tt> and <tt>$stdout</tt>.
  # 
  # The +options+ parameter is also filtered down to FasterCSV::new() after some
  # clever key parsing.  Any key beginning with <tt>:in_</tt> or 
  # <tt>:input_</tt> will have that leading identifier stripped and will only
  # be used in the +options+ Hash for the +input+ object.  Keys starting with
  # <tt>:out_</tt> or <tt>:output_</tt> affect only +output+.  All other keys 
  # are assigned to both objects.
  # 
  # The <tt>:output_row_sep</tt> +option+ defaults to
  # <tt>$INPUT_RECORD_SEPARATOR</tt> (<tt>$/</tt>).
  # 
  def self.filter(*args)
    # parse options for input, output, or both
    in_options, out_options = Hash.new, {:row_sep => $INPUT_RECORD_SEPARATOR}
    if args.last.is_a? Hash
      args.pop.each do |key, value|
        case key.to_s
        when /\Ain(?:put)?_(.+)\Z/
          in_options[$1.to_sym] = value
        when /\Aout(?:put)?_(.+)\Z/
          out_options[$1.to_sym] = value
        else
          in_options[key]  = value
          out_options[key] = value
        end
      end
    end
    # build input and output wrappers
    input   = FasterCSV.new(args.shift || ARGF,    in_options)
    output  = FasterCSV.new(args.shift || $stdout, out_options)
    
    # read, yield, write
    input.each do |row|
      yield row
      output << row
    end
  end
  
  # 
  # This method is intended as the primary interface for reading CSV files.  You
  # pass a +path+ and any +options+ you wish to set for the read.  Each row of
  # file will be passed to the provided +block+ in turn.
  # 
  # The +options+ parameter can be anything FasterCSV::new() understands.
  # 
  def self.foreach(path, options = Hash.new, &block)
    open(path, "rb", options) do |csv|
      csv.each(&block)
    end
  end

  # 
  # :call-seq:
  #   generate( str, options = Hash.new ) { |faster_csv| ... }
  #   generate( options = Hash.new ) { |faster_csv| ... }
  # 
  # This method wraps a String you provide, or an empty default String, in a 
  # FasterCSV object which is passed to the provided block.  You can use the 
  # block to append CSV rows to the String and when the block exits, the 
  # final String will be returned.
  # 
  # Note that a passed String *is* modfied by this method.  Call dup() before
  # passing if you need a new String.
  # 
  # The +options+ parameter can be anthing FasterCSV::new() understands.
  # 
  def self.generate(*args)
    # add a default empty String, if none was given
    if args.first.is_a? String
      io = StringIO.new(args.shift)
      io.seek(0, IO::SEEK_END)
      args.unshift(io)
    else
      args.unshift("")
    end
    faster_csv = new(*args)  # wrap
    yield faster_csv         # yield for appending
    faster_csv.string        # return final String
  end

  # 
  # This method is a shortcut for converting a single row (Array) into a CSV 
  # String.
  # 
  # The +options+ parameter can be anthing FasterCSV::new() understands.
  # 
  # The <tt>:row_sep</tt> +option+ defaults to <tt>$INPUT_RECORD_SEPARATOR</tt>
  # (<tt>$/</tt>) when calling this method.
  # 
  def self.generate_line(row, options = Hash.new)
    options = {:row_sep => $INPUT_RECORD_SEPARATOR}.merge(options)
    (new("", options) << row).string
  end
  
  # 
  # This method will return a FasterCSV instance, just like FasterCSV::new(), 
  # but the instance will be cached and returned for all future calls to this 
  # method for the same +data+ object (tested by Object#object_id()) with the
  # same +options+.
  # 
  # If a block is given, the instance is passed to the block and the return
  # value becomes the return value of the block.
  # 
  def self.instance(data = $stdout, options = Hash.new)
    # create a _signature_ for this method call, data object and options
    sig = [data.object_id] +
          options.values_at(*DEFAULT_OPTIONS.keys.sort_by { |sym| sym.to_s })
    
    # fetch or create the instance for this signature
    @@instances ||= Hash.new
    instance    =   (@@instances[sig] ||= new(data, options))

    if block_given?
      yield instance  # run block, if given, returning result
    else
      instance        # or return the instance
    end
  end
  
  # 
  # This method is the reading counterpart to FasterCSV::dump().  See that
  # method for a detailed description of the process.
  # 
  # You can customize loading by adding a class method called csv_load() which 
  # will be passed a Hash of meta information, an Array of headers, and an Array
  # of fields for the object the method is expected to return.
  # 
  # Remember that all fields will be Strings after this load.  If you need
  # something else, use +options+ to setup converters or provide a custom
  # csv_load() implementation.
  # 
  def self.load(io_or_str, options = Hash.new)
    csv = FasterCSV.new(io_or_str, options)
    
    # load meta information
    meta = Hash[*csv.shift]
    cls  = meta["class"].split("::").inject(Object) do |c, const|
      c.const_get(const)
    end
    
    # load headers
    headers = csv.shift
    
    # unserialize each object stored in the file
    results = csv.inject(Array.new) do |all, row|
      begin
        obj = cls.csv_load(meta, headers, row)
      rescue NoMethodError
        obj = cls.allocate
        headers.zip(row) do |name, value|
          if name[0] == ?@
            obj.instance_variable_set(name, value)
          else
            obj.send(name, value)
          end
        end
      end
      all << obj
    end
    
    csv.close unless io_or_str.is_a? String
    
    results
  end
  
  # 
  # :call-seq:
  #   open( filename, mode="rb", options = Hash.new ) { |faster_csv| ... }
  #   open( filename, mode="rb", options = Hash.new )
  # 
  # This method opens an IO object, and wraps that with FasterCSV.  This is
  # intended as the primary interface for writing a CSV file.
  # 
  # You may pass any +args+ Ruby's open() understands followed by an optional
  # Hash containing any +options+ FasterCSV::new() understands.
  # 
  # This method works like Ruby's open() call, in that it will pass a FasterCSV
  # object to a provided block and close it when the block termminates, or it
  # will return the FasterCSV object when no block is provided.  (*Note*: This
  # is different from the standard CSV library which passes rows to the block.  
  # Use FasterCSV::foreach() for that behavior.)
  # 
  # An opened FasterCSV object will delegate to many IO methods, for 
  # convenience.  You may call:
  # 
  # * binmode()
  # * close()
  # * close_read()
  # * close_write()
  # * closed?()
  # * eof()
  # * eof?()
  # * fcntl()
  # * fileno()
  # * flush()
  # * fsync()
  # * ioctl()
  # * isatty()
  # * pid()
  # * pos()
  # * reopen()
  # * seek()
  # * stat()
  # * sync()
  # * sync=()
  # * tell()
  # * to_i()
  # * to_io()
  # * tty?()
  # 
  def self.open(*args)
    # find the +options+ Hash
    options = if args.last.is_a? Hash then args.pop else Hash.new end
    # default to a binary open mode
    args << "rb" if args.size == 1
    # wrap a File opened with the remaining +args+
    csv     = new(File.open(*args), options)
    
    # handle blocks like Ruby's open(), not like the CSV library
    if block_given?
      begin
        yield csv
      ensure
        csv.close
      end
    else
      csv
    end
  end
  
  # 
  # :call-seq:
  #   parse( str, options = Hash.new ) { |row| ... }
  #   parse( str, options = Hash.new )
  # 
  # This method can be used to easily parse CSV out of a String.  You may either
  # provide a +block+ which will be called with each row of the String in turn,
  # or just use the returned Array of Arrays (when no +block+ is given).
  # 
  # You pass your +str+ to read from, and an optional +options+ Hash containing
  # anything FasterCSV::new() understands.
  # 
  def self.parse(*args, &block)
    csv = new(*args)
    if block.nil?  # slurp contents, if no block is given
      begin
        csv.read
      ensure
        csv.close
      end
    else           # or pass each row to a provided block
      csv.each(&block)
    end
  end
  
  # 
  # This method is a shortcut for converting a single line of a CSV String into 
  # a into an Array.  Note that if +line+ contains multiple rows, anything 
  # beyond the first row is ignored.
  # 
  # The +options+ parameter can be anthing FasterCSV::new() understands.
  # 
  def self.parse_line(line, options = Hash.new)
    new(line, options).shift
  end
  
  # 
  # Use to slurp a CSV file into an Array of Arrays.  Pass the +path+ to the 
  # file and any +options+ FasterCSV::new() understands.
  # 
  def self.read(path, options = Hash.new)
    open(path, "rb", options) { |csv| csv.read }
  end
  
  # Alias for FasterCSV::read().
  def self.readlines(*args)
    read(*args)
  end
  
  # 
  # A shortcut for:
  # 
  #   FasterCSV.read( path, { :headers           => true,
  #                           :converters        => :numeric,
  #                           :header_converters => :symbol }.merge(options) )
  # 
  def self.table(path, options = Hash.new)
    read( path, { :headers           => true,
                  :converters        => :numeric,
                  :header_converters => :symbol }.merge(options) )
  end
  
  # 
  # This constructor will wrap either a String or IO object passed in +data+ for
  # reading and/or writing.  In addition to the FasterCSV instance methods, 
  # several IO methods are delegated.  (See FasterCSV::open() for a complete 
  # list.)  If you pass a String for +data+, you can later retrieve it (after
  # writing to it, for example) with FasterCSV.string().
  # 
  # Note that a wrapped String will be positioned at at the beginning (for 
  # reading).  If you want it at the end (for writing), use 
  # FasterCSV::generate().  If you want any other positioning, pass a preset 
  # StringIO object instead.
  # 
  # You may set any reading and/or writing preferences in the +options+ Hash.  
  # Available options are:
  # 
  # <b><tt>:col_sep</tt></b>::            The String placed between each field.
  # <b><tt>:row_sep</tt></b>::            The String appended to the end of each
  #                                       row.  This can be set to the special
  #                                       <tt>:auto</tt> setting, which requests
  #                                       that FasterCSV automatically discover
  #                                       this from the data.  Auto-discovery
  #                                       reads ahead in the data looking for
  #                                       the next <tt>"\r\n"</tt>,
  #                                       <tt>"\n"</tt>, or <tt>"\r"</tt>
  #                                       sequence.  A sequence will be selected
  #                                       even if it occurs in a quoted field,
  #                                       assuming that you would have the same
  #                                       line endings there.  If none of those
  #                                       sequences is found, +data+ is
  #                                       <tt>ARGF</tt>, <tt>STDIN</tt>,
  #                                       <tt>STDOUT</tt>, or <tt>STDERR</tt>,
  #                                       or the stream is only available for
  #                                       output, the default
  #                                       <tt>$INPUT_RECORD_SEPARATOR</tt>
  #                                       (<tt>$/</tt>) is used.  Obviously,
  #                                       discovery takes a little time.  Set
  #                                       manually if speed is important.  Also
  #                                       note that IO objects should be opened
  #                                       in binary mode on Windows if this
  #                                       feature will be used as the
  #                                       line-ending translation can cause
  #                                       problems with resetting the document
  #                                       position to where it was before the
  #                                       read ahead.
  # <b><tt>:quote_char</tt></b>::         The character used to quote fields.
  #                                       This has to be a single character
  #                                       String.  This is useful for
  #                                       application that incorrectly use
  #                                       <tt>'</tt> as the quote character
  #                                       instead of the correct <tt>"</tt>.
  #                                       FasterCSV will always consider a
  #                                       double sequence this character to be
  #                                       an escaped quote.
  # <b><tt>:encoding</tt></b>::           The encoding to use when parsing the
  #                                       file. Defaults to your <tt>$KDOCE</tt>
  #                                       setting. Valid values: <tt>`n’</tt> or
  #                                       <tt>`N’</tt> for none, <tt>`e’</tt> or
  #                                       <tt>`E’</tt> for EUC, <tt>`s’</tt> or
  #                                       <tt>`S’</tt> for SJIS, and
  #                                       <tt>`u’</tt> or <tt>`U’</tt> for UTF-8
  #                                       (see Regexp.new()).
  # <b><tt>:field_size_limit</tt></b>::   This is a maximum size FasterCSV will
  #                                       read ahead looking for the closing
  #                                       quote for a field.  (In truth, it
  #                                       reads to the first line ending beyond
  #                                       this size.)  If a quote cannot be
  #                                       found within the limit FasterCSV will
  #                                       raise a MalformedCSVError, assuming
  #                                       the data is faulty.  You can use this
  #                                       limit to prevent what are effectively
  #                                       DoS attacks on the parser.  However,
  #                                       this limit can cause a legitimate
  #                                       parse to fail and thus is set to
  #                                       +nil+, or off, by default.
  # <b><tt>:converters</tt></b>::         An Array of names from the Converters
  #                                       Hash and/or lambdas that handle custom
  #                                       conversion.  A single converter
  #                                       doesn't have to be in an Array.
  # <b><tt>:unconverted_fields</tt></b>:: If set to +true+, an
  #                                       unconverted_fields() method will be
  #                                       added to all returned rows (Array or
  #                                       FasterCSV::Row) that will return the
  #                                       fields as they were before convertion.
  #                                       Note that <tt>:headers</tt> supplied
  #                                       by Array or String were not fields of
  #                                       the document and thus will have an
  #                                       empty Array attached.
  # <b><tt>:headers</tt></b>::            If set to <tt>:first_row</tt> or 
  #                                       +true+, the initial row of the CSV
  #                                       file will be treated as a row of
  #                                       headers.  If set to an Array, the
  #                                       contents will be used as the headers.
  #                                       If set to a String, the String is run
  #                                       through a call of
  #                                       FasterCSV::parse_line() with the same
  #                                       <tt>:col_sep</tt>, <tt>:row_sep</tt>,
  #                                       and <tt>:quote_char</tt> as this
  #                                       instance to produce an Array of
  #                                       headers.  This setting causes
  #                                       FasterCSV.shift() to return rows as
  #                                       FasterCSV::Row objects instead of
  #                                       Arrays and FasterCSV.read() to return
  #                                       FasterCSV::Table objects instead of
  #                                       an Array of Arrays.
  # <b><tt>:return_headers</tt></b>::     When +false+, header rows are silently
  #                                       swallowed.  If set to +true+, header
  #                                       rows are returned in a FasterCSV::Row
  #                                       object with identical headers and
  #                                       fields (save that the fields do not go
  #                                       through the converters).
  # <b><tt>:write_headers</tt></b>::      When +true+ and <tt>:headers</tt> is
  #                                       set, a header row will be added to the
  #                                       output.
  # <b><tt>:header_converters</tt></b>::  Identical in functionality to
  #                                       <tt>:converters</tt> save that the
  #                                       conversions are only made to header
  #                                       rows.
  # <b><tt>:skip_blanks</tt></b>::        When set to a +true+ value, FasterCSV
  #                                       will skip over any rows with no
  #                                       content.
  # <b><tt>:force_quotes</tt></b>::       When set to a +true+ value, FasterCSV
  #                                       will quote all CSV fields it creates.
  # 
  # See FasterCSV::DEFAULT_OPTIONS for the default settings.
  # 
  # Options cannot be overriden in the instance methods for performance reasons,
  # so be sure to set what you want here.
  # 
  def initialize(data, options = Hash.new)
    # build the options for this read/write
    options = DEFAULT_OPTIONS.merge(options)
    
    # create the IO object we will read from
    @io = if data.is_a? String then StringIO.new(data) else data end
    
    init_separators(options)
    init_parsers(options)
    init_converters(options)
    init_headers(options)
    
    unless options.empty?
      raise ArgumentError, "Unknown options:  #{options.keys.join(', ')}."
    end
    
    # track our own lineno since IO gets confused about line-ends is CSV fields
    @lineno = 0
  end
  
  # 
  # The line number of the last row read from this file.  Fields with nested 
  # line-end characters will not affect this count.
  # 
  attr_reader :lineno
  
  ### IO and StringIO Delegation ###
  
  extend Forwardable
  def_delegators :@io, :binmode, :close, :close_read, :close_write, :closed?,
                       :eof, :eof?, :fcntl, :fileno, :flush, :fsync, :ioctl,
                       :isatty, :pid, :pos, :reopen, :seek, :stat, :string,
                       :sync, :sync=, :tell, :to_i, :to_io, :tty?
  
  # Rewinds the underlying IO object and resets FasterCSV's lineno() counter.
  def rewind
    @headers = nil
    @lineno  = 0
    
    @io.rewind
  end

  ### End Delegation ###
  
  # 
  # The primary write method for wrapped Strings and IOs, +row+ (an Array or
  # FasterCSV::Row) is converted to CSV and appended to the data source.  When a
  # FasterCSV::Row is passed, only the row's fields() are appended to the
  # output.
  # 
  # The data source must be open for writing.
  # 
  def <<(row)
    # make sure headers have been assigned
    if header_row? and [Array, String].include? @use_headers.class
      parse_headers  # won't read data for Array or String
      self << @headers if @write_headers
    end
    
    # Handle FasterCSV::Row objects and Hashes
    row = case row
          when self.class::Row then row.fields
          when Hash            then @headers.map { |header| row[header] }
          else                      row
          end

    @headers =  row if header_row?
    @lineno  += 1

    @io << row.map(&@quote).join(@col_sep) + @row_sep  # quote and separate
    
    self  # for chaining
  end
  alias_method :add_row, :<<
  alias_method :puts,    :<<
  
  # 
  # :call-seq:
  #   convert( name )
  #   convert { |field| ... }
  #   convert { |field, field_info| ... }
  # 
  # You can use this method to install a FasterCSV::Converters built-in, or 
  # provide a block that handles a custom conversion.
  # 
  # If you provide a block that takes one argument, it will be passed the field
  # and is expected to return the converted value or the field itself.  If your
  # block takes two arguments, it will also be passed a FieldInfo Struct, 
  # containing details about the field.  Again, the block should return a 
  # converted field or the field itself.
  # 
  def convert(name = nil, &converter)
    add_converter(:converters, self.class::Converters, name, &converter)
  end

  # 
  # :call-seq:
  #   header_convert( name )
  #   header_convert { |field| ... }
  #   header_convert { |field, field_info| ... }
  # 
  # Identical to FasterCSV.convert(), but for header rows.
  # 
  # Note that this method must be called before header rows are read to have any
  # effect.
  # 
  def header_convert(name = nil, &converter)
    add_converter( :header_converters,
                   self.class::HeaderConverters,
                   name,
                   &converter )
  end
  
  include Enumerable
  
  # 
  # Yields each row of the data source in turn.
  # 
  # Support for Enumerable.
  # 
  # The data source must be open for reading.
  # 
  def each
    while row = shift
      yield row
    end
  end
  
  # 
  # Slurps the remaining rows and returns an Array of Arrays.
  # 
  # The data source must be open for reading.
  # 
  def read
    rows = to_a
    if @use_headers
      Table.new(rows)
    else
      rows
    end
  end
  alias_method :readlines, :read
  
  # Returns +true+ if the next row read will be a header row.
  def header_row?
    @use_headers and @headers.nil?
  end
  
  # 
  # The primary read method for wrapped Strings and IOs, a single row is pulled
  # from the data source, parsed and returned as an Array of fields (if header
  # rows are not used) or a FasterCSV::Row (when header rows are used).
  # 
  # The data source must be open for reading.
  # 
  def shift
    #########################################################################
    ### This method is purposefully kept a bit long as simple conditional ###
    ### checks are faster than numerous (expensive) method calls.         ###
    #########################################################################
    
    # handle headers not based on document content
    if header_row? and @return_headers and
       [Array, String].include? @use_headers.class
      if @unconverted_fields
        return add_unconverted_fields(parse_headers, Array.new)
      else
        return parse_headers
      end
    end
    
    # begin with a blank line, so we can always add to it
    line = String.new

    # 
    # it can take multiple calls to <tt>@io.gets()</tt> to get a full line,
    # because of \r and/or \n characters embedded in quoted fields
    # 
    loop do
      # add another read to the line
      if read_line = @io.gets(@row_sep)
       line += read_line
      else
       return nil
      end
      # copy the line so we can chop it up in parsing
      parse =  line.dup
      parse.sub!(@parsers[:line_end], "")
      
      # 
      # I believe a blank line should be an <tt>Array.new</tt>, not 
      # CSV's <tt>[nil]</tt>
      # 
      if parse.empty?
        @lineno += 1
        if @skip_blanks
          line = ""
          next
        elsif @unconverted_fields
          return add_unconverted_fields(Array.new, Array.new)
        elsif @use_headers
          return FasterCSV::Row.new(Array.new, Array.new)
        else
          return Array.new
        end
      end

      # parse the fields with a mix of String#split and regular expressions
      csv           = Array.new
      current_field = String.new
      field_quotes  = 0
      parse.split(@col_sep, -1).each do |match|
        if current_field.empty? && match.count(@quote_and_newlines).zero?
          csv           << (match.empty? ? nil : match)
        elsif (current_field.empty? ? match[0] : current_field[0]) ==
              @quote_char[0]
          current_field << match
          field_quotes += match.count(@quote_char)
          if field_quotes % 2 == 0
            in_quotes = current_field[@parsers[:quoted_field], 1]
            raise MalformedCSVError if !in_quotes ||
                                       in_quotes[@parsers[:stray_quote]]
            current_field = in_quotes
            current_field.gsub!(@quote_char * 2, @quote_char) # unescape contents
            csv           << current_field
            current_field =  String.new
            field_quotes  =  0
          else # we found a quoted field that spans multiple lines
            current_field << @col_sep
          end
        elsif match.count("\r\n").zero?
          raise MalformedCSVError, "Illegal quoting on line #{lineno + 1}."
        else
          raise MalformedCSVError, "Unquoted fields do not allow " +
                                   "\\r or \\n (line #{lineno + 1})."
        end
      end

      # if parse is empty?(), we found all the fields on the line...
      if field_quotes % 2 == 0
        @lineno += 1

        # save fields unconverted fields, if needed...
        unconverted = csv.dup if @unconverted_fields

        # convert fields, if needed...
        csv = convert_fields(csv) unless @use_headers or @converters.empty?
        # parse out header rows and handle FasterCSV::Row conversions...
        csv = parse_headers(csv)  if     @use_headers

        # inject unconverted fields and accessor, if requested...
        if @unconverted_fields and not csv.respond_to? :unconverted_fields
          add_unconverted_fields(csv, unconverted)
        end

        # return the results
        break csv
      end
      # if we're not empty?() but at eof?(), a quoted field wasn't closed...
      if @io.eof?
        raise MalformedCSVError, "Unclosed quoted field on line #{lineno + 1}."
      elsif @field_size_limit and current_field.size >= @field_size_limit
        raise MalformedCSVError, "Field size exceeded on line #{lineno + 1}."
      end
      # otherwise, we need to loop and pull some more data to complete the row
    end
  end
  alias_method :gets,     :shift
  alias_method :readline, :shift
  
  # Returns a simplified description of the key FasterCSV attributes.
  def inspect
    str = "<##{self.class} io_type:"
    # show type of wrapped IO
    if    @io == $stdout then str << "$stdout"
    elsif @io == $stdin  then str << "$stdin"
    elsif @io == $stderr then str << "$stderr"
    else                      str << @io.class.to_s
    end
    # show IO.path(), if available
    if @io.respond_to?(:path) and (p = @io.path)
      str << " io_path:#{p.inspect}"
    end
    # show other attributes
    %w[ lineno     col_sep     row_sep
        quote_char skip_blanks encoding ].each do |attr_name|
      if a = instance_variable_get("@#{attr_name}")
        str << " #{attr_name}:#{a.inspect}"
      end
    end
    if @use_headers
      str << " headers:#{(@headers || true).inspect}"
    end
    str << ">"
  end
  
  private
  
  # 
  # Stores the indicated separators for later use.
  # 
  # If auto-discovery was requested for <tt>@row_sep</tt>, this method will read
  # ahead in the <tt>@io</tt> and try to find one.  +ARGF+, +STDIN+, +STDOUT+,
  # +STDERR+ and any stream open for output only with a default
  # <tt>@row_sep</tt> of <tt>$INPUT_RECORD_SEPARATOR</tt> (<tt>$/</tt>).
  # 
  # This method also establishes the quoting rules used for CSV output.
  # 
  def init_separators(options)
    # store the selected separators
    @col_sep            = options.delete(:col_sep)
    @row_sep            = options.delete(:row_sep)
    @quote_char         = options.delete(:quote_char)
    @quote_and_newlines = "#{@quote_char}\r\n"

    if @quote_char.length != 1
      raise ArgumentError, ":quote_char has to be a single character String"
    end
    
    # automatically discover row separator when requested
    if @row_sep == :auto
      if [ARGF, STDIN, STDOUT, STDERR].include?(@io) or
        (defined?(Zlib) and @io.class == Zlib::GzipWriter)
        @row_sep = $INPUT_RECORD_SEPARATOR
      else
        begin
          saved_pos = @io.pos  # remember where we were
          while @row_sep == :auto
            # 
            # if we run out of data, it's probably a single line 
            # (use a sensible default)
            # 
            if @io.eof?
              @row_sep = $INPUT_RECORD_SEPARATOR
              break
            end
      
            # read ahead a bit
            sample =  @io.read(1024)
            sample += @io.read(1) if sample[-1..-1] == "\r" and not @io.eof?
      
            # try to find a standard separator
            if sample =~ /\r\n?|\n/
              @row_sep = $&
              break
            end
          end
          # tricky seek() clone to work around GzipReader's lack of seek()
          @io.rewind
          # reset back to the remembered position
          while saved_pos > 1024  # avoid loading a lot of data into memory
            @io.read(1024)
            saved_pos -= 1024
          end
          @io.read(saved_pos) if saved_pos.nonzero?
        rescue IOError  # stream not opened for reading
          @row_sep = $INPUT_RECORD_SEPARATOR
        end
      end
    end
    
    # establish quoting rules
    do_quote = lambda do |field|
      @quote_char                                      +
      String(field).gsub(@quote_char, @quote_char * 2) +
      @quote_char
    end
    @quote = if options.delete(:force_quotes)
      do_quote
    else
      lambda do |field|
        if field.nil?  # represent +nil+ fields as empty unquoted fields
          ""
        else
          field = String(field)  # Stringify fields
          # represent empty fields as empty quoted fields
          if field.empty? or
             field.count("\r\n#{@col_sep}#{@quote_char}").nonzero?
            do_quote.call(field)
          else
            field  # unquoted field
          end
        end
      end
    end
  end
  
  # Pre-compiles parsers and stores them by name for access during reads.
  def init_parsers(options)
    # store the parser behaviors
    @skip_blanks      = options.delete(:skip_blanks)
    @encoding         = options.delete(:encoding)  # nil will use $KCODE
    @field_size_limit = options.delete(:field_size_limit)

    # prebuild Regexps for faster parsing
    esc_col_sep = Regexp.escape(@col_sep)
    esc_row_sep = Regexp.escape(@row_sep)
    esc_quote   = Regexp.escape(@quote_char)
    @parsers = {
      :any_field    => Regexp.new( "[^#{esc_col_sep}]+",
                                   Regexp::MULTILINE,
                                   @encoding ),
      :quoted_field => Regexp.new( "^#{esc_quote}(.*)#{esc_quote}$",
                                   Regexp::MULTILINE,
                                   @encoding ),
      :stray_quote  => Regexp.new( "[^#{esc_quote}]#{esc_quote}[^#{esc_quote}]",
                                   Regexp::MULTILINE,
                                   @encoding ),
      # safer than chomp!()
      :line_end     => Regexp.new("#{esc_row_sep}\\z", nil, @encoding)
    }
  end
  
  # 
  # Loads any converters requested during construction.
  # 
  # If +field_name+ is set <tt>:converters</tt> (the default) field converters
  # are set.  When +field_name+ is <tt>:header_converters</tt> header converters
  # are added instead.
  # 
  # The <tt>:unconverted_fields</tt> option is also actived for 
  # <tt>:converters</tt> calls, if requested.
  # 
  def init_converters(options, field_name = :converters)
    if field_name == :converters
      @unconverted_fields = options.delete(:unconverted_fields)
    end

    instance_variable_set("@#{field_name}", Array.new)
    
    # find the correct method to add the coverters
    convert = method(field_name.to_s.sub(/ers\Z/, ""))
    
    # load converters
    unless options[field_name].nil?
      # allow a single converter not wrapped in an Array
      unless options[field_name].is_a? Array
        options[field_name] = [options[field_name]]
      end
      # load each converter...
      options[field_name].each do |converter|
        if converter.is_a? Proc  # custom code block
          convert.call(&converter)
        else                     # by name
          convert.call(converter)
        end
      end
    end
    
    options.delete(field_name)
  end
  
  # Stores header row settings and loads header converters, if needed.
  def init_headers(options)
    @use_headers    = options.delete(:headers)
    @return_headers = options.delete(:return_headers)
    @write_headers  = options.delete(:write_headers)

    # headers must be delayed until shift(), in case they need a row of content
    @headers = nil
    
    init_converters(options, :header_converters)
  end
  
  # 
  # The actual work method for adding converters, used by both 
  # FasterCSV.convert() and FasterCSV.header_convert().
  # 
  # This method requires the +var_name+ of the instance variable to place the
  # converters in, the +const+ Hash to lookup named converters in, and the
  # normal parameters of the FasterCSV.convert() and FasterCSV.header_convert()
  # methods.
  # 
  def add_converter(var_name, const, name = nil, &converter)
    if name.nil?  # custom converter
      instance_variable_get("@#{var_name}") << converter
    else          # named converter
      combo = const[name]
      case combo
      when Array  # combo converter
        combo.each do |converter_name|
          add_converter(var_name, const, converter_name)
        end
      else        # individual named converter
        instance_variable_get("@#{var_name}") << combo
      end
    end
  end
  
  # 
  # Processes +fields+ with <tt>@converters</tt>, or <tt>@header_converters</tt>
  # if +headers+ is passed as +true+, returning the converted field set.  Any
  # converter that changes the field into something other than a String halts
  # the pipeline of conversion for that field.  This is primarily an efficiency
  # shortcut.
  # 
  def convert_fields(fields, headers = false)
    # see if we are converting headers or fields
    converters = headers ? @header_converters : @converters
    
    fields.enum_for(:each_with_index).map do |field, index|  # map_with_index
      converters.each do |converter|
        field = if converter.arity == 1  # straight field converter
          converter[field]
        else                             # FieldInfo converter
          header = @use_headers && !headers ? @headers[index] : nil
          converter[field, FieldInfo.new(index, lineno, header)]
        end
        break unless field.is_a? String  # short-curcuit pipeline for speed
      end
      field  # return final state of each field, converted or original
    end
  end
  
  # 
  # This methods is used to turn a finished +row+ into a FasterCSV::Row.  Header
  # rows are also dealt with here, either by returning a FasterCSV::Row with
  # identical headers and fields (save that the fields do not go through the
  # converters) or by reading past them to return a field row. Headers are also
  # saved in <tt>@headers</tt> for use in future rows.
  # 
  # When +nil+, +row+ is assumed to be a header row not based on an actual row
  # of the stream.
  # 
  def parse_headers(row = nil)
    if @headers.nil?                # header row
      @headers = case @use_headers  # save headers
                 # Array of headers
                 when Array  then @use_headers
                 # CSV header String
                 when String
                   self.class.parse_line( @use_headers,
                                          :col_sep    => @col_sep,
                                          :row_sep    => @row_sep,
                                          :quote_char => @quote_char )
                 # first row is headers
                 else             row
                 end
      
      # prepare converted and unconverted copies
      row      = @headers                       if row.nil?
      @headers = convert_fields(@headers, true)
      
      if @return_headers                                     # return headers
        return FasterCSV::Row.new(@headers, row, true)
      elsif not [Array, String].include? @use_headers.class  # skip to field row
        return shift
      end
    end

    FasterCSV::Row.new(@headers, convert_fields(row))  # field row
  end
  
  # 
  # Thiw methods injects an instance variable <tt>unconverted_fields</tt> into
  # +row+ and an accessor method for it called unconverted_fields().  The
  # variable is set to the contents of +fields+.
  # 
  def add_unconverted_fields(row, fields)
    class << row
      attr_reader :unconverted_fields
    end
    row.instance_eval { @unconverted_fields = fields }
    row
  end
end

# Another name for FasterCSV.
FCSV = FasterCSV

# Another name for FasterCSV::instance().
def FasterCSV(*args, &block)
  FasterCSV.instance(*args, &block)
end

# Another name for FCSV::instance().
def FCSV(*args, &block)
  FCSV.instance(*args, &block)
end

class Array
  # Equivalent to <tt>FasterCSV::generate_line(self, options)</tt>.
  def to_csv(options = Hash.new)
    FasterCSV.generate_line(self, options)
  end
end

class String
  # Equivalent to <tt>FasterCSV::parse_line(self, options)</tt>.
  def parse_csv(options = Hash.new)
    FasterCSV.parse_line(self, options)
  end
end

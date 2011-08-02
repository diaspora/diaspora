require 'sqlite3/constants'
require 'sqlite3/errors'

module SQLite3

  # The ResultSet object encapsulates the enumerability of a query's output.
  # It is a simple cursor over the data that the query returns. It will
  # very rarely (if ever) be instantiated directly. Instead, client's should
  # obtain a ResultSet instance via Statement#execute.
  class ResultSet
    include Enumerable

    # The class of which we return an object in case we want an Array as
    # result. (ArrayFields is installed.)
    class ArrayWithTypes < Array
      attr_accessor :types
    end

    # The class of which we return an object in case we want an Array as
    # result. (ArrayFields is not installed.)
    class ArrayWithTypesAndFields < Array
      attr_accessor :types
      attr_accessor :fields
    end

    # The class of which we return an object in case we want a Hash as
    # result.
    class HashWithTypes < Hash
      attr_accessor :types
    end

    # Create a new ResultSet attached to the given database, using the
    # given sql text.
    def initialize db, stmt
      @db   = db
      @stmt = stmt
    end

    # Reset the cursor, so that a result set which has reached end-of-file
    # can be rewound and reiterated.
    def reset( *bind_params )
      @stmt.reset!
      @stmt.bind_params( *bind_params )
      @eof = false
    end

    # Query whether the cursor has reached the end of the result set or not.
    def eof?
      @stmt.done?
    end

    # Obtain the next row from the cursor. If there are no more rows to be
    # had, this will return +nil+. If type translation is active on the
    # corresponding database, the values in the row will be translated
    # according to their types.
    #
    # The returned value will be an array, unless Database#results_as_hash has
    # been set to +true+, in which case the returned value will be a hash.
    #
    # For arrays, the column names are accessible via the +fields+ property,
    # and the column types are accessible via the +types+ property.
    #
    # For hashes, the column names are the keys of the hash, and the column
    # types are accessible via the +types+ property.
    def next
      row = @stmt.step
      return nil if @stmt.done?

      if @db.type_translation
        row = @stmt.types.zip(row).map do |type, value|
          @db.translator.translate( type, value )
        end
      end

      if @db.results_as_hash
        new_row = HashWithTypes[*@stmt.columns.zip(row).flatten]
        row.each_with_index { |value,idx|
          new_row[idx] = value
        }
        row = new_row
      else
        if row.respond_to?(:fields)
          row = ArrayWithTypes.new(row)
        else
          row = ArrayWithTypesAndFields.new(row)
        end
        row.fields = @stmt.columns
      end

      row.types = @stmt.types
      row
    end

    # Required by the Enumerable mixin. Provides an internal iterator over the
    # rows of the result set.
    def each( &block )
      while node = self.next
        yield node
      end
    end

    # Closes the statement that spawned this result set.
    # <em>Use with caution!</em> Closing a result set will automatically
    # close any other result sets that were spawned from the same statement.
    def close
      @stmt.close
    end

    # Queries whether the underlying statement has been closed or not.
    def closed?
      @stmt.closed?
    end

    # Returns the types of the columns returned by this result set.
    def types
      @stmt.types
    end

    # Returns the names of the columns returned by this result set.
    def columns
      @stmt.columns
    end

  end

end

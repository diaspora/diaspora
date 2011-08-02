require 'sqlite3/errors'

module SQLite3

  # This module is intended for inclusion solely by the Database class. It
  # defines convenience methods for the various pragmas supported by SQLite3.
  #
  # For a detailed description of these pragmas, see the SQLite3 documentation
  # at http://sqlite.org/pragma.html.
  module Pragmas

    # Returns +true+ or +false+ depending on the value of the named pragma.
    def get_boolean_pragma( name )
      get_first_value( "PRAGMA #{name}" ) != "0"
    end
    private :get_boolean_pragma

    # Sets the given pragma to the given boolean value. The value itself
    # may be +true+ or +false+, or any other commonly used string or
    # integer that represents truth.
    def set_boolean_pragma( name, mode )
      case mode
        when String
          case mode.downcase
            when "on", "yes", "true", "y", "t"; mode = "'ON'"
            when "off", "no", "false", "n", "f"; mode = "'OFF'"
            else
              raise Exception,
                "unrecognized pragma parameter #{mode.inspect}"
          end
        when true, 1
          mode = "ON"
        when false, 0, nil
          mode = "OFF"
        else
          raise Exception,
            "unrecognized pragma parameter #{mode.inspect}"
      end

      execute( "PRAGMA #{name}=#{mode}" )
    end
    private :set_boolean_pragma

    # Requests the given pragma (and parameters), and if the block is given,
    # each row of the result set will be yielded to it. Otherwise, the results
    # are returned as an array.
    def get_query_pragma( name, *parms, &block ) # :yields: row
      if parms.empty?
        execute( "PRAGMA #{name}", &block )
      else
        args = "'" + parms.join("','") + "'"
        execute( "PRAGMA #{name}( #{args} )", &block )
      end
    end
    private :get_query_pragma

    # Return the value of the given pragma.
    def get_enum_pragma( name )
      get_first_value( "PRAGMA #{name}" )
    end
    private :get_enum_pragma

    # Set the value of the given pragma to +mode+. The +mode+ parameter must
    # conform to one of the values in the given +enum+ array. Each entry in
    # the array is another array comprised of elements in the enumeration that
    # have duplicate values. See #synchronous, #default_synchronous,
    # #temp_store, and #default_temp_store for usage examples.
    def set_enum_pragma( name, mode, enums )
      match = enums.find { |p| p.find { |i| i.to_s.downcase == mode.to_s.downcase } }
      raise Exception,
        "unrecognized #{name} #{mode.inspect}" unless match
      execute( "PRAGMA #{name}='#{match.first.upcase}'" )
    end
    private :set_enum_pragma

    # Returns the value of the given pragma as an integer.
    def get_int_pragma( name )
      get_first_value( "PRAGMA #{name}" ).to_i
    end
    private :get_int_pragma

    # Set the value of the given pragma to the integer value of the +value+
    # parameter.
    def set_int_pragma( name, value )
      execute( "PRAGMA #{name}=#{value.to_i}" )
    end
    private :set_int_pragma

    # The enumeration of valid synchronous modes.
    SYNCHRONOUS_MODES = [ [ 'full', 2 ], [ 'normal', 1 ], [ 'off', 0 ] ]

    # The enumeration of valid temp store modes.
    TEMP_STORE_MODES  = [ [ 'default', 0 ], [ 'file', 1 ], [ 'memory', 2 ] ]

    # Does an integrity check on the database. If the check fails, a
    # SQLite3::Exception will be raised. Otherwise it
    # returns silently.
    def integrity_check
      execute( "PRAGMA integrity_check" ) do |row|
        raise Exception, row[0] if row[0] != "ok"
      end
    end

    def auto_vacuum
      get_boolean_pragma "auto_vacuum"
    end

    def auto_vacuum=( mode )
      set_boolean_pragma "auto_vacuum", mode
    end

    def schema_cookie
      get_int_pragma "schema_cookie"
    end

    def schema_cookie=( cookie )
      set_int_pragma "schema_cookie", cookie
    end

    def user_cookie
      get_int_pragma "user_cookie"
    end

    def user_cookie=( cookie )
      set_int_pragma "user_cookie", cookie
    end

    def cache_size
      get_int_pragma "cache_size"
    end

    def cache_size=( size )
      set_int_pragma "cache_size", size
    end

    def default_cache_size
      get_int_pragma "default_cache_size"
    end

    def default_cache_size=( size )
      set_int_pragma "default_cache_size", size
    end

    def default_synchronous
      get_enum_pragma "default_synchronous"
    end

    def default_synchronous=( mode )
      set_enum_pragma "default_synchronous", mode, SYNCHRONOUS_MODES
    end

    def synchronous
      get_enum_pragma "synchronous"
    end

    def synchronous=( mode )
      set_enum_pragma "synchronous", mode, SYNCHRONOUS_MODES
    end

    def default_temp_store
      get_enum_pragma "default_temp_store"
    end

    def default_temp_store=( mode )
      set_enum_pragma "default_temp_store", mode, TEMP_STORE_MODES
    end
  
    def temp_store
      get_enum_pragma "temp_store"
    end

    def temp_store=( mode )
      set_enum_pragma "temp_store", mode, TEMP_STORE_MODES
    end

    def full_column_names
      get_boolean_pragma "full_column_names"
    end

    def full_column_names=( mode )
      set_boolean_pragma "full_column_names", mode
    end
  
    def parser_trace
      get_boolean_pragma "parser_trace"
    end

    def parser_trace=( mode )
      set_boolean_pragma "parser_trace", mode
    end
  
    def vdbe_trace
      get_boolean_pragma "vdbe_trace"
    end

    def vdbe_trace=( mode )
      set_boolean_pragma "vdbe_trace", mode
    end

    def database_list( &block ) # :yields: row
      get_query_pragma "database_list", &block
    end

    def foreign_key_list( table, &block ) # :yields: row
      get_query_pragma "foreign_key_list", table, &block
    end

    def index_info( index, &block ) # :yields: row
      get_query_pragma "index_info", index, &block
    end

    def index_list( table, &block ) # :yields: row
      get_query_pragma "index_list", table, &block
    end

    ###
    # Returns information about +table+.  Yields each row of table information
    # if a block is provided.
    def table_info table
      stmt    = prepare "PRAGMA table_info(#{table})"
      columns = stmt.columns

      needs_tweak_default =
        version_compare(SQLite3.libversion.to_s, "3.3.7") > 0

      result = [] unless block_given?
      stmt.each do |row|
        new_row = Hash[columns.zip(row)]

        # FIXME: This should be removed but is required for older versions
        # of rails
        if(Object.const_defined?(:ActiveRecord))
          new_row['notnull'] = new_row['notnull'].to_s
        end

        tweak_default(new_row) if needs_tweak_default

        if block_given?
          yield new_row
        else
          result << new_row
        end
      end
      stmt.close

      result
    end

    private

      # Compares two version strings
      def version_compare(v1, v2)
        v1 = v1.split(".").map { |i| i.to_i }
        v2 = v2.split(".").map { |i| i.to_i }
        parts = [v1.length, v2.length].max
        v1.push 0 while v1.length < parts
        v2.push 0 while v2.length < parts
        v1.zip(v2).each do |a,b|
          return -1 if a < b
          return  1 if a > b
        end
        return 0
      end

      # Since SQLite 3.3.8, the table_info pragma has returned the default
      # value of the row as a quoted SQL value. This method essentially
      # unquotes those values.
      def tweak_default(hash)
        case hash["dflt_value"]
        when /^null$/i
          hash["dflt_value"] = nil
        when /^'(.*)'$/
          hash["dflt_value"] = $1.gsub(/''/, "'")
        when /^"(.*)"$/
          hash["dflt_value"] = $1.gsub(/""/, '"')
        end
      end
  end

end

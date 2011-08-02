require "delegate"

module DBI
    # DBI::Row is the representation of a row in a result set returned by the
    # database.
    #
    # It is responsible for containing and representing the result set, converting
    # it to native Ruby types, and providing methods to sanely move through itself. 
    #
    # The DBI::Row class is a delegate of Array, rather than a subclass, because
    # there are times when it should act like an Array, and others when it should
    # act like a Hash (and still others where it should act like String, Regexp,
    # etc).  It also needs to store metadata about the row, such as
    # column data type and index information, that users can then access.
    #
    class Row < DelegateClass(Array)
        attr_reader :column_names

        # DBI::Row.new(columns, column_types, size_or_array=nil)
        #
        # Returns a new DBI::Row object using +columns+.  The +size_or_array+
        # argument may either be an Integer or an Array.  If it is not provided,
        # it defaults to the length of +columns+.
        #
        # Column types is a corresponding Array of Class/Module objects that
        # conform to the DBI::Type interface. These will be used to convert types
        # as they are returned.
        #
        # DBI::Row is a delegate of the Array class, so all of the Array
        # instance methods are available to your DBI::Row object (keeping in
        # mind that initialize, [], and []= have been explicitly overridden).
        #
        def initialize(columns, column_types, size_or_array=nil, convert_types=true)
            @column_types = column_types
            @convert_types = convert_types
            size_or_array ||= columns.size 
            
            # The '@column_map' is used to map column names to integer values so
            # that users can reference row values by name or number.

            @column_map   = {}
            @column_names = columns
            columns.each_with_index { |c,i| @column_map[c] = i }

            case size_or_array
            when Integer
                super(@arr = Array.new(size_or_array))
            when Array
                super(@arr = size_or_array.dup)
                set_values(size_or_array.dup)
            else
                raise TypeError, "parameter must be either Integer or Array"
            end
        end

        # converts the types in the array to their specified representation
        # from column types provided at construction time.
        def convert_types(arr)
            return arr.dup unless @convert_types

            if arr.size != @column_types.size
                raise TypeError, "Type mapping is not consistent with result"
            end
            new_arr = []
            arr.each_with_index do |item, i|
                new_arr.push((@column_types[i] || DBI::Type::Varchar).parse(item))
            end

            return new_arr
        end

        # Replaces the contents of the internal array with +new_values+.
        # elements are type converted at this time.
        def set_values(new_values)
            @arr.replace(convert_types(new_values))
        end

        # Yields a column value by name (rather than index), along with the
        # column name itself.
        def each_with_name
            @arr.each_with_index do |v, i|
                yield v, @column_names[i]
            end 
        end

        # returns the underlying array (duplicated)
        def to_a
            @arr.dup
        end

        # Returns the Row object as a hash, created by #each_with_name.
        def to_h
            hash = {}
            each_with_name{ |v, n| hash[n] = v}
            hash
        end

        # Create a new row with 'new_values', reusing the field name hash.
        # Initial cloning is done deeply, via Marshal.
        def clone_with(new_values)
            obj = clone
            obj.set_values(new_values)

            return obj
        end

        alias field_names column_names

        # Retrieve a value by index (rather than name).
        #
        # Deprecated.  Since Row delegates to Array, just use Row#at.
        def by_index(index)
            @arr[index]
        end

        # Value of the field named +field_name+ or nil if not found.
        def by_field(field_name)
            begin
                @arr[@column_map[field_name.to_s]]
            rescue TypeError
                nil
            end
        end

        # Row#[]
        #
        # row[int]
        # row[array]
        # row[regexp]
        # row[arg, arg]
        # row[arg, arg, ...]
        #
        # Sample: Row.new(["first","last","age"], ["Daniel", "Berger", "36"])
        #
        # Retrieves row elements.  Exactly what it retrieves depends on the
        # kind and number of arguments used.
        #
        # Zero arguments will raise an ArgumentError.
        #
        # One argument will return a single result.  This can be a String,
        # Symbol, Integer, Range or Regexp and the appropriate result will
        # be returned.  Strings, Symbols and Regexps act like hash lookups,
        # while Integers and Ranges act like Array index lookups.
        #
        # Two arguments will act like the second form of Array#[], i.e it takes
        # two integers, with the first number the starting point and the second
        # number the length, and returns an array of values.
        #
        # If three or more arguments are provided, an array of results is
        # returned.  The behavior for each argument is that of a single argument,
        # i.e. Strings, Symbols, and Regexps act like hash lookups, while
        # Integers and Ranges act like Array index lookups.
        # 
        # If no results are found, or an unhandled type is passed, then nil
        # (or a nil element) is returned.
        #
        def [](*args)
            begin
                case args.length
                when 0
                    err = "wrong # of arguments(#{args.size} for at least 1)"
                    raise ArgumentError, err
                when 1
                    case args[0]
                    when Array
                        args[0].collect { |e| self[e] }
                    when Regexp
                        self[@column_names.grep(args[0])] 
                    else
                        @arr[conv_param(args[0])]
                    end
                    # We explicitly check for a length of 2 in order to properly
                    # simulate the second form of Array#[].
                when 2
                    @arr[conv_param(args[0]), conv_param(args[1])]
                else
                    results = []
                    args.flatten.each{ |arg|
                        case arg
                        when Integer
                            results.push(@arr[arg])
                        when Regexp
                            results.push(self[@column_names.grep(arg)])
                        else
                            results.push(self[conv_param(arg)])
                        end
                    }
                    results.flatten
                end
            rescue TypeError
                nil
            end
        end

        # Assign a value to a Row object by element.  You can assign using
        # a single element reference, or by using a start and length similar
        # to the second form of Array#[]=.
        #
        # row[0]     = "kirk"
        # row[:last] = "haines"
        # row[0, 2]  = "test" 
        #
        def []=(key, value_or_length, obj=nil)
            if obj
                @arr[conv_param(key), conv_param(value_or_length)] = obj
            else
                @arr[conv_param(key)] = value_or_length
            end
        end


        if RUBY_VERSION =~ /^1\.9/
            def __getobj__
                @arr
            end

            def __setobj__(obj)
                @delegate_dc_obj = @arr = obj
            end
        else
            #
            # See Object#clone.
            #
            # #clone and #dup here, however, are both deep copies via Marshal.
            #
            def clone
                Marshal.load(Marshal.dump(self))
            end

            def dup
                row = self.class.allocate
                row.instance_variable_set :@column_types,  @column_types
                row.instance_variable_set :@convert_types, @convert_types
                row.instance_variable_set :@column_map,    @column_map
                row.instance_variable_set :@column_names,  @column_names
                # this is the only one we actually dup...
                row.instance_variable_set :@arr,           arr = @arr.dup
                row.instance_variable_set :@_dc_obj,       arr
                row
            end
        end

        private

        # Simple helper method to grab the proper value from @column_map
        # NOTE this does something completely different than DBI::Utils::ConvParam
        def conv_param(arg) # :nodoc:
            case arg
            when String, Symbol
                @column_map[arg.to_s]
            when Range
                if arg.first.kind_of?(Symbol) || arg.first.kind_of?(String)
                    first = @column_map[arg.first.to_s]
                    last  = @column_map[arg.last.to_s]
                else
                    first = arg.first
                    last  = arg.last
                end

                if arg.exclude_end?
                    (first...last) 
                else
                    (first..last)
                end
            else
                arg
            end
        end
    end # class Row
end # module DBI

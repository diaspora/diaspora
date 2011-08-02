module DBI
    module SQL
        #
        # The PreparedStatement class attempts to provide binding functionality
        # for database systems that do not have this built-in. This package
        # emulates the whole concept of a statement.
        #
        class PreparedStatement
            attr_accessor :unbound

            # Convenience method for consumers that just need the tokens
            # method.
            def self.tokens(sql)
                self.new(nil, sql).tokens
            end

            #
            # "prepare" a statement.
            #
            # +quoter+ is deprecated and will eventually disappear, it is kept
            # currently for compatibility. It is safe to pass nil to this parameter.
            #
            # +sql+ is the statement itself.
            #
            def initialize(quoter, sql)
                @quoter, @sql = quoter, sql
                prepare
            end

            # Break the sql string into parts.
            #
            # This is NOT a full lexer for SQL.  It just breaks up the SQL
            # string enough so that question marks, double question marks and
            # quoted strings are separated.  This is used when binding
            # arguments to "?" in the SQL string.  
            #
            # C-style (/* */) and Ada-style (--) comments are handled.
            # Note:: Nested C-style comments are NOT handled!
            #
            def tokens
                @sql.scan(%r{
                    (
                        -- .*                               (?# matches "--" style comments to the end of line or string )
                        |   -                                   (?# matches single "-" )
                        |
                        /[*] .*? [*]/                       (?# matches C-style comments )
                        |   /                                   (?# matches single slash )    
                        |
                        ' ( [^'\\]  |  ''  |  \\. )* '  (?# match strings surrounded by apostophes )
                        |
                        " ( [^"\\]  |  ""  |  \\. )* "      (?# match strings surrounded by " )
                        |
                        \?\??                               (?# match one or two question marks )
                        |
                        [^-/'"?]+                           (?# match all characters except ' " ? - and / )

                )}x).collect {|t| t.first}
            end

            # attempts to bind the arguments in +args+ to this statement.
            # Will raise StandardError if there are any extents issues.
            def bind(args)
                if @arg_index < args.size
                    raise "Too many SQL parameters"
                elsif @arg_index > args.size
                    raise "Not enough SQL parameters"
                end

                @unbound.each do |res_pos, arg_pos|
                    @result[res_pos] = args[arg_pos]
                end

                @result.join("")
            end

            private

            # prepares the statement for binding. This is done by scanning the
            # statement and itemizing what needs to be bound and what does not.
            # 
            # This information will then be used by #bind to appropriately map
            # parameters to the intended destinations.
            def prepare
                @result = [] 
                @unbound = {}
                pos = 0
                @arg_index = 0

                tokens.each { |part|
                    case part
                    when '?'
                        @result[pos] = nil
                        @unbound[pos] = @arg_index
                        pos += 1
                        @arg_index += 1
                    when '??'
                        if @result[pos-1] != nil
                            @result[pos-1] << "?"
                        else
                            @result[pos] = "?"
                            pos += 1
                        end
                    else
                        if @result[pos-1] != nil
                            @result[pos-1] << part
                        else
                            @result[pos] = part
                            pos += 1
                        end
                    end
                }
            end
        end # PreparedStatement
    end
end

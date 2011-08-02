module DBI
    #
    # StatementHandle is the interface the consumer sees after successfully
    # issuing a DatabaseHandle#prepare. They may also be exposed through other
    # methods that send statements to the database.
    #
    # Almost all methods in this class will raise InterfaceError if the
    # statement is already finished.
    #
    class StatementHandle < Handle

        include Enumerable

        attr_accessor :dbh
        attr_accessor :raise_error

        def initialize(handle, fetchable=false, prepared=true, convert_types=true, executed=false)
            super(handle)
            @fetchable = fetchable
            @prepared  = prepared     # only false if immediate execute was used
            @executed  = executed     # only true if the statement was already executed.
            @cols = nil
            @coltypes = nil
            @convert_types = convert_types

            if @fetchable
                @row = DBI::Row.new(column_names, column_types, nil, @convert_types)
            else
                @row = nil
            end
        end

        # Returns true if the StatementHandle has had #finish called on it,
        # explicitly or otherwise.
        def finished?
            @handle.nil?
        end

        # Returns true if the statement is believed to return data upon #fetch.
        #
        # The current reliability of this (and the concept in general) is
        # suspect.
        def fetchable?
            @fetchable
        end

        #
        # Instruct successive calls to #fetch to cast the type returned into
        # `type`, for row position `pos`. Like all bind_* calls, `pos` indexes
        # starting at 1.
        #
        # `type` is an object with the DBI::Type calling convention.
        #
        # This call must be called after #execute has successfully ran,
        # otherwise it will raise InterfaceError.
        #
        # Example:
        #  # `foo` is an integer and this statement will return two rows. 
        #  sth = dbh.prepare("select foo from bar") 
        #  # would raise InterfaceError if called here
        #  sth.execute
        #
        #  sth.bind_coltype(1, DBI::Type::Varchar) 
        #  # would normally use DBI::Type::Integer and return a Fixnum. We'll make it a string.
        #  sth.fetch => ["1"]
        #
        #  # Here we coerce it to Float.
        #  sth.bind_coltype(1, DBI::Type::Float)
        #  sth.fetch => [1.0]
        #  sth.finish
        #
        def bind_coltype(pos, type)
            sanity_check({:prepared => true, :executed => true})
            
            coltypes = column_types

            if (pos - 1) < 0
                raise InterfaceError, "bind positions index starting at 1"
            end

            coltypes[pos-1] = type
            @row = DBI::Row.new(column_names, coltypes, nil, @convert_types)
        end

        #
        # Just like BaseStatement#bind_param, but will attempt to convert the
        # type if it's supposed to, adhering to the DBD's current ruleset.
        #
        def bind_param(param, value, attribs=nil)
            sanity_check({ :prepared => true })

            if @convert_types
                value = DBI::Utils::ConvParam.conv_param(dbh.driver_name, value)[0]
            end

            @handle.bind_param(param, value, attribs)
        end


        # Execute the statement.
        #
        # This generally means that the statement will be sent to the database
        # and some form of result cursor will be obtained, but is ultimately
        # driver-dependent.
        #
        # If arguments are supplied, these are fed to #bind_param.
        def execute(*bindvars)
            cancel     # cancel before 
            sanity_check({:prepared => true })

            if @convert_types
                bindvars = DBI::Utils::ConvParam.conv_param(dbh.driver_name, *bindvars)
            end

            @handle.bind_params(*bindvars)
            @handle.execute
            @fetchable = true
            @executed = true

            # TODO:?
            #if @row.nil?
            @row = DBI::Row.new(column_names, column_types, nil, @convert_types)
            #end
            return nil
        end

        #
        # Finish the statement, causing the database to release all assets
        # related to it (any result cursors, normally).
        #
        # StatementHandles that have already been finished will normally be
        # inoperable and unavailable for further use.
        #
        def finish
            sanity_check
            @handle.finish
            @handle = nil
        end

        #
        # Cancel the query, closing any open result cursors and truncating any result sets.
        #
        # The difference between this and #finish is that cancelled statements
        # may be re-executed.
        #
        def cancel
            sanity_check
            @handle.cancel if @fetchable
            @fetchable = false
        end

        #
        # Obtains the column names for this query as an array.
        #
        def column_names
            sanity_check
            return @cols unless @cols.nil?
            @cols = @handle.column_info.collect {|col| col['name'] }
        end

        #
        # Obtain the type mappings for the columns in this query based on
        # ColumnInfo data on the query.
        #
        # The result will be a position-dependent array of objects that conform
        # to the DBI::Type calling syntax.
        #
        def column_types
            sanity_check
            return @coltypes unless @coltypes.nil?
            @coltypes = @handle.column_info.collect do |col| 
                if col['dbi_type']
                    col['dbi_type']
                else
                    DBI::TypeUtil.type_name_to_module(col['type_name'])
                end
            end
        end

        #
        # See BaseStatement#column_info.
        #
        def column_info
            sanity_check
            @handle.column_info.collect {|col| ColumnInfo.new(col) }
        end

        #
        # Should return the row modified count as the result of statement execution.
        #
        # However, some low-level drivers do not supply this information or
        # supply misleading information (> 0 rows for read-only select
        # statements, f.e.)
        #
        def rows
            sanity_check
            @handle.rows
        end


        #
        # See BaseStatement#fetch.
        #
        # fetch can also take a block which will be applied to each row in a
        # similar fashion to Enumerable#collect. See #each.
        #
        def fetch(&p)
            sanity_check({ :fetchable => true, :prepared => true, :executed => true })

            if block_given? 
                while (res = @handle.fetch) != nil
                    @row = @row.dup
                    @row.set_values(res)
                    yield @row
                end
                @handle.cancel
                @fetchable = false
                return nil
            else
                res = @handle.fetch
                if res.nil?
                    @handle.cancel
                    @fetchable = false
                else
                    @row = @row.dup
                    @row.set_values(res)
                    res = @row
                end
                return res
            end
        end

        #
        # Synonym for #fetch with a block.
        #
        def each(&p)
            sanity_check({:fetchable => true, :prepared => true, :executed => true})
            raise InterfaceError, "No block given" unless block_given?

            fetch(&p)
        end

        #
        # Similar to #fetch, but returns Array of Array instead of Array of
        # DBI::Row objects (and therefore does not perform type mapping). This
        # is basically a way to get the raw data from the DBD.
        #
        def fetch_array
            sanity_check({:fetchable => true, :prepared => true, :executed => true})

            if block_given? 
                while (res = @handle.fetch) != nil
                    yield res
                end
                @handle.cancel
                @fetchable = false
                return nil
            else
                res = @handle.fetch
                if res.nil?
                    @handle.cancel
                    @fetchable = false
                end
                return res
            end
        end

        #
        # Map the columns and results into an Array of Hash resultset.
        #
        # No type conversion is performed here. Expect this to change in 0.6.0.
        #
        def fetch_hash
            sanity_check({:fetchable => true, :prepared => true, :executed => true})

            cols = column_names

            if block_given? 
                while (row = @handle.fetch) != nil
                    hash = {}
                    row.each_with_index {|v,i| hash[cols[i]] = v} 
                    yield hash
                end
                @handle.cancel
                @fetchable = false
                return nil
            else
                row = @handle.fetch
                if row.nil?
                    @handle.cancel
                    @fetchable = false
                    return nil
                else
                    hash = {}
                    row.each_with_index {|v,i| hash[cols[i]] = v} 
                    return hash
                end
            end
        end

        #
        # Fetch `cnt` rows. Result is array of DBI::Row
        #
        def fetch_many(cnt)
            sanity_check({:fetchable => true, :prepared => true, :executed => true})

            cols = column_names
            rows = @handle.fetch_many(cnt)
            if rows.nil? or rows.empty?
                @handle.cancel
                @fetchable = false
                return []
            else
                return rows.collect{|r| tmp = @row.dup; tmp.set_values(r); tmp }
            end
        end

        # 
        # Fetch the entire result set. Result is array of DBI::Row.
        #
        def fetch_all
            sanity_check({:fetchable => true, :prepared => true, :executed => true})

            cols = column_names
            fetched_rows = []

            begin
                while row = fetch do
                    fetched_rows.push(row)
                end
            rescue Exception
            end

            @handle.cancel
            @fetchable = false

            return fetched_rows
        end

        #
        # See BaseStatement#fetch_scroll.
        #
        def fetch_scroll(direction, offset=1)
            sanity_check({:fetchable => true, :prepared => true, :executed => true})

            row = @handle.fetch_scroll(direction, offset)
            if row.nil?
                #@handle.cancel
                #@fetchable = false
                return nil
            else
                @row.set_values(row)
                return @row
            end
        end

        # Get an attribute from the StatementHandle object.
        def [] (attr)
            sanity_check
            @handle[attr]
        end

        # Set an attribute on the StatementHandle object.
        def []= (attr, val)
            sanity_check
            @handle[attr] = val
        end
        
        protected

        def sanity_check(params={})
            raise InterfaceError, "Statement was already closed!" if @handle.nil?

            params.each_key do |key|
                case key
                when :fetchable
                    check_fetchable
                when :executed
                    check_executed
                when :prepared
                    check_prepared
                when :statement
                    check_statement(params[:statement])
                end
            end
        end

        def check_prepared
            raise InterfaceError, "Statement wasn't prepared before." unless @prepared
        end

        def check_fetchable
            if !@fetchable and @raise_error
                raise InterfaceError, "Statement does not have any data for fetching." 
            end
        end

        def check_executed
            raise InterfaceError, "Statement hasn't been executed yet." unless @executed
        end

        # basic sanity checks for statements
        def check_statement(stmt)
            raise InterfaceError, "Statement is empty, or contains nothing but whitespace" if stmt !~ /\S/
        end

    end # class StatementHandle
end

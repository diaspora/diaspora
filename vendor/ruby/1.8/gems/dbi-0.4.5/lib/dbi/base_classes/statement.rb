module DBI
    #
    # StatementHandles are used to encapsulate the process of managing a
    # statement (DDL or DML) and its parameters, sending it to the database,
    # and gathering any results from the execution of that statement.
    #
    # As with the other `Base` classes, the terms "DBD Required" and "DBD
    # Optional" are defined in DBI::BaseDatabase.
    #
    class BaseStatement < Base

        attr_accessor :raise_error

        def initialize(attr=nil)
            @attr = attr || {}
        end

        #
        # Bind a parameter to the statement. DBD Required.
        #
        # The parameter number is numeric and indexes starting at 1. This
        # corresponds to the question marks (?) in the statement from the
        # left-most part of the statement moving forward.
        #
        # The value may be any ruby type. How these are handled is
        # DBD-dependent, but the vast majority of DBDs will convert these to
        # string inside the query.
        #
        def bind_param(param, value, attribs)
            raise NotImplementedError
        end

        #
        # Execute the statement with the known binds. DBD Required.
        #
        def execute
            raise NotImplementedError
        end

        #
        # Close the statement and any result cursors. DBD Required.
        #
        # Note:: Most implementations will fail miserably if you forget to
        #        finish your statement handles.
        def finish
            raise NotImplementedError
        end

        #
        # Fetch the next row in the result set. DBD Required.
        #
        # DBI::Row is responsible for formatting the data the DBD provides it.
        #
        def fetch
            raise NotImplementedError
        end

        ##
        # returns result-set column information as array
        # of hashs, where each hash represents one column. See
        # BaseDatabase#columns. DBD Required.
        #
        def column_info
            raise NotImplementedError
        end

        #============================================
        # OPTIONAL
        #============================================

        #
        # Take a list of bind variables and bind them successively using bind_param.
        #
        def bind_params(*bindvars)
            bindvars.each_with_index {|val,i| bind_param(i+1, val, nil) }
            self
        end

        #
        # Cancel any result cursors. DBD Optional, but intentionally does not
        # raise any exception as it's used internally to maintain consistency.
        #
        def cancel
        end

        #
        # fetch_scroll is provided with a direction and offset and works
        # similar to how seek() is used on files.
        #
        # The constants available for direction are as follows:
        # 
        # * SQL_FETCH_NEXT: fetch the next result.
        # * SQL_FETCH_LAST: fetch the last result, period.
        # * SQL_FETCH_RELATIVE: fetch the result at the offset. 
        #
        # Other constants can be used, but if this method is not supplied by
        # the driver, they will result in a raise of DBI::NotSupportedError.
        #

        def fetch_scroll(direction, offset)
            case direction
            when SQL_FETCH_NEXT
                return fetch
            when SQL_FETCH_LAST
                last_row = nil
                while (row=fetch) != nil
                    last_row = row
                end
                return last_row
            when SQL_FETCH_RELATIVE
                raise NotSupportedError if offset <= 0
                row = nil
                offset.times { row = fetch; break if row.nil? }
                return row
            else
                raise NotSupportedError
            end
        end

        #
        # fetch x rows. The result is Array of DBI::Row.
        #
        def fetch_many(cnt)
            rows = []
            cnt.times do
                row = fetch
                break if row.nil?
                rows << row.dup
            end

            if rows.empty?
                nil
            else
                rows
            end
        end

        #
        # Fetch all available rows. Result is Array of DBI::Row.
        #
        def fetch_all
            rows = []
            loop do
                row = fetch
                break if row.nil?
                rows << row.dup
            end

            if rows.empty?
                nil
            else
                rows
            end
        end

        #
        # Get statement attributes.
        #
        def [](attr)
            @attr ||= { }
            @attr[attr]
        end

        #
        # Set statement attributes. DBD Optional.
        #
        def []=(attr, value)
            raise NotSupportedError
        end
    end # class BaseStatement
end

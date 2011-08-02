module DBI
    # Provides the core-level functionality for DatabaseHandles.
    # 
    # If the method description says "DBD Required", it's the DBD's
    # responsibility to create this method. 
    # 
    # Required methods unimplemented by the DBD will raise
    # DBD::NotImplementedError.
    #
    # "DBD Optional" methods are methods that do not have a default
    # implementation but are optional due to the fact that many databases may
    # not support these features (and emulating them would be prohibitive). 
    #
    # These methods raise DBI::NotSupportedError.
    #
    # Otherwise, DBI will provide a general alternative which should meet the
    # expectations of the documentation. However, DBDs can override every
    # method in this class.
    #
    class BaseDatabase < Base
        def initialize(handle, attr)
            @handle = handle
            @attr   = {}
            attr.each {|k,v| self[k] = v} 
        end

        # Disconnect from the database. DBD Required.
        def disconnect
            raise NotImplementedError
        end

        # Ping the database to ensure the connection is still alive. Boolean
        # return, true for success. DBD Required.
        def ping
            raise NotImplementedError
        end

        # Prepare a cached statement, returning a StatementHandle. DBD
        # Required.
        def prepare(statement)
            raise NotImplementedError
        end

        #
        # Return a map of the columns that exist in the provided table name.
        # DBD Required.
        #
        # The result should be an array of DBI::ColumnInfo objects which have,
        # at minimum, the following fields: 
        #
        # * name:: the name of the column.
        # * type:: This is not a field name in itself. You have two options:
        #   * type_name:: The name of the type as returned by the database
        #   * dbi_type:: A DBI::Type-conforming class that can be used to convert to a native type.
        # * precision:: the precision (generally length) of the column
        # * scale:: the scale (generally a secondary attribute to precision
        #   that helps indicate length) of the column
        #
        def columns(table)
            raise NotImplementedError
        end
        
        #============================================
        # OPTIONAL
        #============================================

        # Schedule a commit to the database immediately. DBD Optional.
        def commit
            raise NotSupportedError
        end

        # Schedule a rollback to the database immediately. DBD Optional.
        def rollback
            raise NotSupportedError
        end

        # Return the tables available to the database connection.
        # 
        # Note:: the basic implementation returns an empty array.
        def tables
            []
        end

        # 
        # Execute a statement with the binds provided. Returns the statement
        # handle unfinished.
        #
        # This is roughly equivalent to:
        #
        #   sth = dbh.prepare("my statement")
        #   sth.execute(my, bind, vars)
        #   
        def execute(statement, *bindvars)
            stmt = prepare(statement)
            stmt.bind_params(*bindvars)
            stmt.execute
            stmt
        end

        #
        # Execute and complete the statement with the binds provided. Returns
        # the row modified count (via BaseStatement#rows). Finishes the
        # statement handle for you.
        #
        # Roughly equivalent to:
        #
        #   sth = dbh.prepare("my statement")
        #   sth.execute(my, bind, vars)
        #   result = sth.rows
        #   sth.finish
        #
        # Returning the value stored in `result`.
        def do(statement, *bindvars)
            stmt = execute(statement, *bindvars)
            res = stmt.rows
            stmt.finish
            return res
        end

        #
        # Get an attribute from the DatabaseHandle. These are DBD specific and
        # embody things like Auto-Commit support for transactional databases.
        #
        # DBD Authors:: This messes with @attr directly.
        #
        def [](attr)
            @attr[attr]
        end

        # Set an attribute on the DatabaseHandle. DBD Optional.
        def []=(attr, value)
            raise NotSupportedError
        end
    end # class BaseDatabase
end

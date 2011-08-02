module DBI
    # DriverHandles, while not directly exposed, are essentially the backend
    # for the facade that many DBI root-level methods communicate with.
    class DriverHandle < Handle

        attr_writer :driver_name

        # Connect to the database. The DSN will have been parsed at this point
        # and the named parameters should need no explanation.
        #
        # If a block is provided to DBI.connect, the connected DatabaseHandle
        # will be provided as the first argument to the block, and the
        # DatabaseHandle will be disconnected upon block exit.
        #
        def connect(db_args, user, auth, params)

            user = @handle.default_user[0] if user.nil?
            auth = @handle.default_user[1] if auth.nil?

            # TODO: what if only one of them is nil?
            #if user.nil? and auth.nil? then
            #  user, auth = @handle.default_user
            #end

            params ||= {}
            new_params = @handle.default_attributes
            params.each {|k,v| new_params[k] = v} 

            if params.has_key?(:_convert_types)
                @convert_types = params[:_convert_types]
            end

            db = @handle.connect(db_args, user, auth, new_params)
            dbh = DatabaseHandle.new(db, @convert_types)
            # FIXME trace
            # dbh.trace(@trace_mode, @trace_output)
            dbh.driver_name = @driver_name

            if block_given?
                begin
                    yield dbh
                ensure  
                    dbh.disconnect if dbh.connected?
                end  
            else
                return dbh
            end
        end

        # See BaseDriver#data_sources.
        def data_sources
            @handle.data_sources
        end

        # See BaseDriver#disconnect_all.
        def disconnect_all
            @handle.disconnect_all
        end
    end
end

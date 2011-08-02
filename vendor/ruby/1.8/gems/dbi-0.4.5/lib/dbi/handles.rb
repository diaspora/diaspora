#
# Dispatch classes (Handle, DriverHandle, DatabaseHandle and StatementHandle)
#

module DBI
    #
    # Base class for all handles.
    #
    class Handle
        attr_reader :trace_mode, :trace_output
        attr_reader :handle 
        attr :convert_types, true

        def initialize(handle, convert_types=true)
            @handle = handle
            @trace_mode = @trace_output = nil
            @convert_types = convert_types
        end

        # Please seee DBI.trace.
        def trace(mode=nil, output=nil)
            # FIXME trace
            raise InterfaceError, "the trace module has been removed until it actually works."
            @trace_mode   = mode   || @trace_mode   || DBI::DEFAULT_TRACE_MODE
            @trace_output = output || @trace_output || DBI::DEFAULT_TRACE_OUTPUT
        end

        #
        # Leverage a driver-specific method. The method name will have "__"
        # prepended to them before calling, and the DBD must define them as
        # such for them to work.
        #
        def func(function, *values)
            if @handle.respond_to?("__" + function.to_s) then
                @handle.send("__" + function.to_s, *values)  
            else
                raise InterfaceError, "Driver specific function <#{function}> not available."
            end
        rescue ArgumentError
            raise InterfaceError, "Wrong # of arguments for driver specific function"
        end

        # error functions?
    end
end

require 'dbi/handles/driver'
require 'dbi/handles/database'
require 'dbi/handles/statement'

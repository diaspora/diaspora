module DBI
    #
    # Encapsulates the concept of a CLOB/BLOB, which can then be passed as a
    # bind via BaseStatement#bind_param.
    #
    # This is similar to a DBI::Type class and will eventually find its way
    # there.
    #
    # See #new for usage.
    class Binary
        attr_accessor :data

        # Construct a new DBI::Binary object with the data supplied as string.
        # This object can then be used in bound variables to represent a CLOB
        # or BLOB type.
        def initialize(data)
            @data = data
        end

        # Return the string representation of the DBI::Binary object.
        def to_s
            @data
        end
    end
end

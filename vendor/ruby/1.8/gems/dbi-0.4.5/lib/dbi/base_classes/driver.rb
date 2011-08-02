module DBI

    # Implements the basic functionality that constitutes a Driver
    #
    # Drivers do not have a direct interface exposed to the user; these methods
    # are mostly for DBD authors.
    #
    # As with DBI::BaseDatabase, "DBD Required" and "DBD Optional" will be used
    # to explain the same requirements.
    #
    class BaseDriver < Base
        def initialize(dbi_version)
            major, minor = dbi_version.split(".").collect { |x| x.to_i }
            dbi_major, dbi_minor = DBI::VERSION.split(".").collect { |x| x.to_i }
            unless major == dbi_major and minor == dbi_minor
                raise InterfaceError, "Wrong DBD API version used"
            end
        end

        # Connect to the database. DBD Required.
        def connect(dbname, user, auth, attr)
            raise NotImplementedError
        end

        # Default u/p information in an array.
        def default_user
            ['', '']
        end

        # Default attributes to set on the DatabaseHandle.
        def default_attributes
            {}
        end

        # Return the data sources available to this driver. Returns an empty
        # array per default.
        def data_sources
            []
        end

        # Disconnect all DatabaseHandles. DBD Required.
        def disconnect_all
            raise NotImplementedError
        end

    end # class BaseDriver
end

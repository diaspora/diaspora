module DBI
    #  Exceptions (borrowed by Python API 2.0)

    # Base class of all other error exceptions.  Use this to catch all DBI
    # errors.
    class Error < RuntimeError
    end

    # For important warnings like data truncation, etc.
    class Warning < RuntimeError
    end

    # Exception for errors related to the DBI interface rather than the
    # database itself.
    class InterfaceError < Error
    end

    # Exception raised if the DBD driver has not specified a mandatory method.
    class NotImplementedError < InterfaceError
    end

    # Exception for errors related to the database.
    class DatabaseError < Error
        attr_reader :err, :errstr, :state

        def initialize(errstr="", err=nil, state=nil)
            super(errstr)
            @err, @errstr, @state = err, errstr, state
        end
    end

    # Exception for errors due to problems with the processed 
    # data such as division by zero, numeric value out of range, etc.
    class DataError < DatabaseError
    end

    # Exception for errors related to the database's operation which are not
    # necessarily under the control of the programmer.  This includes such
    # things as unexpected disconnect, datasource name not found, transaction
    # could not be processed, a memory allocation error occured during
    # processing, etc.
    class OperationalError < DatabaseError
    end

    # Exception raised when the relational integrity of the database
    # is affected, e.g. a foreign key check fails.
    class IntegrityError < DatabaseError
    end

    # Exception raised when the database encounters an internal error, 
    # e.g. the cursor is not valid anymore, the transaction is out of sync.
    class InternalError < DatabaseError
    end

    # Exception raised for programming errors, e.g. table not found
    # or already exists, syntax error in SQL statement, wrong number
    # of parameters specified, etc.
    class ProgrammingError < DatabaseError
    end

    # Exception raised if e.g. commit() is called for a database which do not
    # support transactions.
    class NotSupportedError < DatabaseError
    end
end

module DBI
    #  Constants

    # Constants for fetch_scroll
    #
    SQL_FETCH_NEXT     = 1
    SQL_FETCH_PRIOR    = 2
    SQL_FETCH_FIRST    = 3
    SQL_FETCH_LAST     = 4
    SQL_FETCH_ABSOLUTE = 5
    SQL_FETCH_RELATIVE = 6

    # SQL type constants
    # 
    SQL_CHAR       = 1
    SQL_NUMERIC    = 2
    SQL_DECIMAL    = 3
    SQL_INTEGER    = 4
    SQL_SMALLINT   = 5
    SQL_FLOAT      = 6
    SQL_REAL       = 7
    SQL_DOUBLE     = 8
    SQL_DATE       = 9  # 91
    SQL_TIME       = 10 # 92 
    SQL_TIMESTAMP  = 11 # 93 
    SQL_VARCHAR    = 12
    SQL_BOOLEAN    = 13

    SQL_LONGVARCHAR   = -1
    SQL_BINARY        = -2
    SQL_VARBINARY     = -3
    SQL_LONGVARBINARY = -4
    SQL_BIGINT        = -5
    SQL_TINYINT       = -6
    SQL_BIT           = -7

    # TODO
    # Find types for these (XOPEN?)
    #SQL_ARRAY = 
    SQL_BLOB = -10   # TODO
    SQL_CLOB = -11   # TODO
    #SQL_DISTINCT = 
    #SQL_OBJECT = 
    #SQL_NULL = 
    SQL_OTHER = 100
    #SQL_REF = 
    #SQL_STRUCT = 

    SQL_TYPE_NAMES = {
        SQL_BIT               => 'BIT',
        SQL_TINYINT           => 'TINYINT',
        SQL_SMALLINT          => 'SMALLINT',
        SQL_INTEGER           => 'INTEGER',
        SQL_BIGINT            => 'BIGINT',
        SQL_FLOAT             => 'FLOAT',
        SQL_REAL              => 'REAL',
        SQL_DOUBLE            => 'DOUBLE',
        SQL_NUMERIC           => 'NUMERIC',
        SQL_DECIMAL           => 'DECIMAL',
        SQL_CHAR              => 'CHAR',
        SQL_VARCHAR           => 'VARCHAR',
        SQL_LONGVARCHAR       => 'LONG VARCHAR',
        SQL_DATE              => 'DATE',
        SQL_TIME              => 'TIME',
        SQL_TIMESTAMP         => 'TIMESTAMP',
        SQL_BINARY            => 'BINARY',
        SQL_VARBINARY         => 'VARBINARY',
        SQL_LONGVARBINARY     => 'LONG VARBINARY',
        SQL_BLOB              => 'BLOB',
        SQL_CLOB              => 'CLOB',
        SQL_OTHER             => nil,
        SQL_BOOLEAN           => 'BOOLEAN',

    }
end

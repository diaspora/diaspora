#
# $Id: sql.rb,v 1.3 2006/03/27 20:25:02 francis Exp $
#
# parts extracted from Jim Weirichs DBD::Pg
#

require "dbi/utils"
require "time"

module DBI
    # the SQL package contains assistance for DBDs and generally will not be
    # needed outside of them.
    module SQL
        # Helper to determine if the statement is a query. Very crude and
        # should not be relied on for accuracy.
        def self.query?(sql)
            sql =~ /^\s*select\b/i
        end
    end # module SQL
end # module DBI

require 'dbi/sql/preparedstatement'

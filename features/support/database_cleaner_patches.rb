#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# disable_referential_integrity doesn't work when using PostgreSQL
# with a non-root user.
# See http://kopongo.com/2008/7/25/postgres-ri_constrainttrigger-error
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def disable_referential_integrity(&block)
         transaction {
           begin
             execute "SET CONSTRAINTS ALL DEFERRED"
             yield
           ensure
             execute "SET CONSTRAINTS ALL IMMEDIATE"
           end
         }
      end
    end
  end
end

DatabaseCleaner::ActiveRecord::Truncation.class_eval do
  # You could argue that this technically isn't truncation. You'd be right.
  # But something in the MySQL adapter segfaults (!) on actual truncation, and we
  # don't have that much data in our tests, so a DELETE is not appreciably slower.
  def clean
    connection.disable_referential_integrity do
      tables_to_truncate.each do |table_name|
        connection.execute("DELETE FROM #{table_name};")
      end
    end
  end
end

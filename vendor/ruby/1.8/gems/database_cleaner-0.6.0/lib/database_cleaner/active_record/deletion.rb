require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'
require 'database_cleaner/active_record/truncation'
# This file may seem to have duplication with that of truncation, but by keeping them separate
# we avoiding loading this code when it is not being used (which is the common case).

module ActiveRecord
  module ConnectionAdapters

    class MysqlAdapter < MYSQL_ADAPTER_PARENT
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class Mysql2Adapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter < AbstractAdapter
      def delete_table(table_name)
          execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class SQLServerAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class OracleEnhancedAdapter < AbstractAdapter
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)}")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Deletion < Truncation

    def clean
      connection.disable_referential_integrity do
        tables_to_truncate.each do |table_name|
          connection.delete_table table_name
        end
      end
    end

  end
end



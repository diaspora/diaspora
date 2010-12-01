require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/truncation_base"

module ActiveRecord
  module ConnectionAdapters

    class AbstractAdapter
    end

    class SQLiteAdapter < AbstractAdapter
    end

    class MysqlAdapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class SQLite3Adapter < SQLiteAdapter
      def truncate_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
    end

    class JdbcAdapter < AbstractAdapter
      def truncate_table(table_name)
        begin
          execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
        rescue ActiveRecord::StatementInvalid
          execute("DELETE FROM #{quote_table_name(table_name)};")
        end
      end
    end

    class PostgreSQLAdapter < AbstractAdapter

      def self.db_version
        @db_version ||= ActiveRecord::Base.connection.select_values(
          "SELECT CHARACTER_VALUE 
            FROM INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO 
            WHERE IMPLEMENTATION_INFO_NAME = 'DBMS VERSION' ").to_s
      end

      def self.cascade
        @cascade ||= db_version >=  "08.02" ? "CASCADE" : ""
      end

      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)} #{self.class.cascade};")
      end

    end

    class SQLServerAdapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class OracleEnhancedAdapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}")
      end
    end

  end
end


module DatabaseCleaner::ActiveRecord
  class Truncation < ::DatabaseCleaner::TruncationBase

    def clean
      connection.disable_referential_integrity do
        tables_to_truncate.each do |table_name|
          connection.truncate_table table_name
        end
      end
    end

    private

    def tables_to_truncate
      (@only || connection.tables) - @tables_to_exclude
    end

    def connection
      ::ActiveRecord::Base.connection
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end

  end
end



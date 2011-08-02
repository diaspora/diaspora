require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require "database_cleaner/generic/truncation"
require 'database_cleaner/active_record/base'

module ActiveRecord
  module ConnectionAdapters
    # Activerecord-jdbc-adapter defines class dependencies a bit differently - if it is present, confirm to ArJdbc hierarchy to avoid 'superclass mismatch' errors.
    USE_ARJDBC_WORKAROUND = defined?(ArJdbc)

    class AbstractAdapter
    end

    unless USE_ARJDBC_WORKAROUND
      class SQLiteAdapter < AbstractAdapter
      end
    end

    MYSQL_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : AbstractAdapter
    SQLITE_ADAPTER_PARENT = USE_ARJDBC_WORKAROUND ? JdbcAdapter : SQLiteAdapter

    class MysqlAdapter < MYSQL_ADAPTER_PARENT
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class Mysql2Adapter < AbstractAdapter
      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)};")
      end
    end

    class SQLite3Adapter < SQLITE_ADAPTER_PARENT
      def delete_table(table_name)
        execute("DELETE FROM #{quote_table_name(table_name)};")
      end
      alias truncate_table delete_table
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

      def db_version
        @db_version ||= select_values(
          "SELECT CHARACTER_VALUE
            FROM INFORMATION_SCHEMA.SQL_IMPLEMENTATION_INFO
            WHERE IMPLEMENTATION_INFO_NAME = 'DBMS VERSION' ").join.to_s
      end

      def cascade
        @cascade ||= db_version >=  "08.02" ? "CASCADE" : ""
      end

      def truncate_table(table_name)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)} #{cascade};")
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
  class Truncation
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Truncation

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
       #::ActiveRecord::Base.connection
       connection_klass.connection
    end

    # overwritten
    def migration_storage_name
      'schema_migrations'
    end

  end
end



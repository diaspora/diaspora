module Foreigner
  module ConnectionAdapters
    module Sql2003
      def supports_foreign_keys?
        true
      end
    
      def add_foreign_key(from_table, to_table, options = {})
        column  = options[:column] || "#{to_table.to_s.singularize}_id"
        foreign_key_name = foreign_key_name(from_table, column, options)
        primary_key = options[:primary_key] || "id"
        dependency = dependency_sql(options[:dependent])

        sql =
          "ALTER TABLE #{quote_table_name(from_table)} " +
          "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
          "FOREIGN KEY (#{quote_column_name(column)}) " +
          "REFERENCES #{quote_table_name(ActiveRecord::Migrator.proper_table_name(to_table))}(#{primary_key})"
        sql << " #{dependency}" if dependency.present?
        sql << " #{options[:options]}" if options[:options]
      
        execute(sql)
      end

      private
        def foreign_key_name(table, column, options = {})
          if options[:name]
            options[:name]
          else
            "#{table}_#{column}_fk"
          end
        end

        def dependency_sql(dependency)
          case dependency
            when :nullify then "ON DELETE SET NULL"
            when :delete  then "ON DELETE CASCADE"
            when :restrict then "ON DELETE RESTRICT"
            else ""
          end
        end
    end
  end
end
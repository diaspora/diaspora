module Foreigner
  module SchemaDumper
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        alias_method_chain :tables, :foreign_keys
      end
    end
    
    module InstanceMethods
      def tables_with_foreign_keys(stream)
        tables_without_foreign_keys(stream)
        @connection.tables.sort.each do |table|
          foreign_keys(table, stream)
        end
      end
      
      private
        def foreign_keys(table_name, stream)
          if (foreign_keys = @connection.foreign_keys(table_name)).any?
            add_foreign_key_statements = foreign_keys.map do |foreign_key|
              statement_parts = [ ('add_foreign_key ' + foreign_key.from_table.inspect) ]
              statement_parts << foreign_key.to_table.inspect
              statement_parts << (':name => ' + foreign_key.options[:name].inspect)
              
              if foreign_key.options[:column] != "#{foreign_key.to_table.singularize}_id"
                statement_parts << (':column => ' + foreign_key.options[:column].inspect)
              end
              if foreign_key.options[:primary_key] != 'id'
                statement_parts << (':primary_key => ' + foreign_key.options[:primary_key].inspect)
              end
              if foreign_key.options[:dependent].present?
                statement_parts << (':dependent => ' + foreign_key.options[:dependent].inspect)
              end

              '  ' + statement_parts.join(', ')
            end

            stream.puts add_foreign_key_statements.sort.join("\n")
            stream.puts
          end
        end
    end
  end
end
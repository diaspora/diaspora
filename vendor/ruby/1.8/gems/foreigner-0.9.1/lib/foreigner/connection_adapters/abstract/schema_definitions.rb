module Foreigner
  module ConnectionAdapters
    class ForeignKeyDefinition < Struct.new(:from_table, :to_table, :options) #:nodoc:
    end
    
    module SchemaDefinitions
      def self.included(base)
        base::Table.class_eval do
          include Foreigner::ConnectionAdapters::Table
        end
      end
    end
  
    module Table
      def self.included(base)
        base.class_eval do
          include InstanceMethods
          alias_method_chain :references, :foreign_keys
        end
      end

      module InstanceMethods
        # Adds a new foreign key to the table. +to_table+ can be a single Symbol, or
        # an Array of Symbols. See SchemaStatements#add_foreign_key
        #
        # ===== Examples
        # ====== Creating a simple foreign key
        #  t.foreign_key(:people)
        # ====== Defining the column
        #  t.foreign_key(:people, :column => :sender_id)
        # ====== Creating a named foreign key
        #  t.foreign_key(:people, :column => :sender_id, :name => 'sender_foreign_key')
        # ====== Defining the column of the +to_table+.
        #  t.foreign_key(:people, :column => :sender_id, :primary_key => :person_id)
        def foreign_key(to_table, options = {})
          @base.add_foreign_key(@table_name, to_table, options)
        end
    
        # Remove the given foreign key from the table.
        #
        # ===== Examples
        # ====== Remove the suppliers_company_id_fk in the suppliers table.
        #   t.remove_foreign_key :companies
        # ====== Remove the foreign key named accounts_branch_id_fk in the accounts table.
        #   remove_foreign_key :column => :branch_id
        # ====== Remove the foreign key named party_foreign_key in the accounts table.
        #   remove_index :name => :party_foreign_key
        def remove_foreign_key(options = {})
          @base.remove_foreign_key(@table_name, options)
        end
      
        # Adds a :foreign_key option to Table.references.
        # If :foreign_key is true, a foreign key constraint is added to the table.
        # You can also specify a hash, which is passed as foreign key options.
        # 
        # ===== Examples
        # ====== Add goat_id column and a foreign key to the goats table.
        #  t.references(:goat, :foreign_key => true)
        # ====== Add goat_id column and a cascading foreign key to the goats table.
        #  t.references(:goat, :foreign_key => {:dependent => :delete})
        # 
        # Note: No foreign key is created if :polymorphic => true is used.
        def references_with_foreign_keys(*args)
          options = args.extract_options!
          polymorphic = options[:polymorphic]
          fk_options = options.delete(:foreign_key)

          references_without_foreign_keys(*(args.dup << options))

          if fk_options && !polymorphic
            fk_options = {} if fk_options == true
            args.each { |to_table| foreign_key(to_table, fk_options) }
          end
        end
      end
    end
  end
end

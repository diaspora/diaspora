module ActiveRecord::Import::MysqlAdapter
  module InstanceMethods
    def self.included(klass)
      klass.instance_eval do
        include ActiveRecord::Import::ImportSupport  
        include ActiveRecord::Import::OnDuplicateKeyUpdateSupport
      end
    end
    
    # Returns the maximum number of bytes that the server will allow
    # in a single packet
    def max_allowed_packet # :nodoc:
      result = execute( "SHOW VARIABLES like 'max_allowed_packet';" )
      # original Mysql gem responds to #fetch_row while Mysql2 responds to #first
      val = result.respond_to?(:fetch_row) ? result.fetch_row[1] : result.first[1]
      val.to_i
    end
    
    # Returns a generated ON DUPLICATE KEY UPDATE statement given the passed
    # in +args+. 
    def sql_for_on_duplicate_key_update( table_name, *args ) # :nodoc:
      sql = ' ON DUPLICATE KEY UPDATE '
      arg = args.first
      if arg.is_a?( Array )
        sql << sql_for_on_duplicate_key_update_as_array( table_name, arg )
      elsif arg.is_a?( Hash )
        sql << sql_for_on_duplicate_key_update_as_hash( table_name, arg )
      elsif arg.is_a?( String )
        sql << arg
      else
        raise ArgumentError.new( "Expected Array or Hash" )
      end
      sql
    end

    def sql_for_on_duplicate_key_update_as_array( table_name, arr )  # :nodoc:
      results = arr.map do |column|
        qc = quote_column_name( column )
        "#{table_name}.#{qc}=VALUES(#{qc})"        
      end
      results.join( ',' )
    end
  
    def sql_for_on_duplicate_key_update_as_hash( table_name, hsh ) # :nodoc:
      sql = ' ON DUPLICATE KEY UPDATE '
      results = hsh.map do |column1, column2|
        qc1 = quote_column_name( column1 )
        qc2 = quote_column_name( column2 )
        "#{table_name}.#{qc1}=VALUES( #{qc2} )"
      end
      results.join( ',')
    end

    #return true if the statement is a duplicate key record error
    def duplicate_key_update_error?(exception)# :nodoc:
      exception.is_a?(ActiveRecord::StatementInvalid) && exception.to_s.include?('Duplicate entry')
    end
  end
end
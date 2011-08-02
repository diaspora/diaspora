class ActiveRecord::Base
  class << self
    def establish_connection_with_activerecord_import(*args)
      establish_connection_without_activerecord_import(*args)
      ActiveSupport.run_load_hooks(:active_record_connection_established, connection)
    end
    alias_method_chain :establish_connection, :activerecord_import
  end
end

ActiveSupport.on_load(:active_record_connection_established) do |connection|
  if !ActiveRecord.const_defined?(:Import) || !ActiveRecord::Import.respond_to?(:load_from_connection)
    require File.join File.dirname(__FILE__),  "activerecord-import/base"
  end
  ActiveRecord::Import.load_from_connection connection
end

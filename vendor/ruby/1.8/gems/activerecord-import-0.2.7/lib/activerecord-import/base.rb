require "pathname"
require "active_record"
require "active_record/version"

module ActiveRecord::Import
  AdapterPath = File.join File.expand_path(File.dirname(__FILE__)), "/active_record/adapters"

  # Loads the import functionality for a specific database adapter
  def self.require_adapter(adapter)
    require File.join(AdapterPath,"/abstract_adapter")
    require File.join(AdapterPath,"/#{adapter}_adapter")
  end

  # Loads the import functionality for the passed in ActiveRecord connection
  def self.load_from_connection(connection)
    import_adapter = "ActiveRecord::Import::#{connection.class.name.demodulize}::InstanceMethods"
    unless connection.class.ancestors.map(&:name).include?(import_adapter)
      config = connection.instance_variable_get :@config
      require_adapter config[:adapter]
    end
  end
end


this_dir = Pathname.new File.dirname(__FILE__)
require this_dir.join("import")
require this_dir.join("active_record/adapters/abstract_adapter")
require this_dir.join("synchronize")
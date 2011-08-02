require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/connection_adapters/sql_2003'
require 'foreigner/schema_dumper'

module Foreigner
  class << self
    def adapters
      @@adapters ||= {}
    end

    def register(adapter_name, file_name)
      adapters[adapter_name] = file_name
    end

    def load_adapter!
      ActiveRecord::ConnectionAdapters.module_eval do
        include Foreigner::ConnectionAdapters::SchemaStatements
        include Foreigner::ConnectionAdapters::SchemaDefinitions
      end

      ActiveRecord::SchemaDumper.class_eval do
        include Foreigner::SchemaDumper
      end

      if adapters.key?(configured_adapter)
        require adapters[configured_adapter]
      end
    end

    def configured_adapter
      ActiveRecord::Base.connection_pool.spec.config[:adapter]
    end
  end
end

Foreigner.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'mysql2', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

if defined?(Rails::Railtie)
  module Foreigner
    class Railtie < Rails::Railtie
      initializer 'foreigner.load_adapter' do
        ActiveSupport.on_load :active_record do
          Foreigner.load_adapter!
        end
      end
    end
  end
else
  Foreigner.load_adapter!
end
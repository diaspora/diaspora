module ActiveRecord::Import::PostgreSQLAdapter
  module InstanceMethods
    def self.included(klass)
      klass.instance_eval do
        include ActiveRecord::Import::ImportSupport
      end
    end

    def next_value_for_sequence(sequence_name)
      %{nextval('#{sequence_name}')}
    end
  end
end

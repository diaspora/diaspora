module ActiveRecord::Import::Sqlite3Adapter
  module InstanceMethods
    def next_value_for_sequence(sequence_name)
      %{nextval('#{sequence_name}')}
    end
  end
end

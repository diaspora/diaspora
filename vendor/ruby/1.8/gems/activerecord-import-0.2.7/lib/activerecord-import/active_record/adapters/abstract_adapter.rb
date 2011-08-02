require "activerecord-import/adapters/abstract_adapter"

module ActiveRecord # :nodoc:
  module ConnectionAdapters # :nodoc:
    class AbstractAdapter # :nodoc:
      extend ActiveRecord::Import::AbstractAdapter::ClassMethods
      include ActiveRecord::Import::AbstractAdapter::InstanceMethods
    end
  end
end

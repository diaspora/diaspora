require 'dm-core'

module DataMapper
  module Model
    include OrmAdapter::ToAdapter
  end
  
  module Resource
    class OrmAdapter < ::OrmAdapter::Base

      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ::DataMapper::Model.descendants.to_a.select{|k| !except_classes.include?(k.name)}
      end

      # get a list of column names for a given class
      def column_names
        klass.properties.map(&:name)
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass.get!(id)
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.get(id)
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.first :conditions => conditions, :order => order_clause(order)
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options)
        conditions, order = extract_conditions_and_order!(options)
        klass.all :conditions => conditions, :order => order_clause(order)
      end
    
      # @see OrmAdapter::Base#create!
      def create!(attributes)
        klass.create(attributes)
      end
      
    protected
      
      def order_clause(order)
        order.map {|pair| pair.first.send(pair.last)}
      end
    end
  end
end

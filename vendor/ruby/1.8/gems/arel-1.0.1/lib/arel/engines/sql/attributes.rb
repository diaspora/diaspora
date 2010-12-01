module Arel
  module Sql
    module Attributes
      def self.for(column)
        case column.type
        when :string    then String
        when :text      then String
        when :integer   then Integer
        when :float     then Float
        when :decimal   then Decimal
        when :date      then Time
        when :datetime  then Time
        when :timestamp then Time
        when :time      then Time
        when :binary    then String
        when :boolean   then Boolean
        else
          Undefined
        end
      end

      def initialize(column, *args)
        @column = column
        super(*args)
      end

      def type_cast(value)
        @column.type_cast(value)
      end

      # Attribute type for column types that Arel doesn't know how to handle.
      class Undefined < Arel::Attribute
        include Attributes
      end

      %w(Boolean Decimal Float Integer String Time).each do |klass|
        class_eval <<-R
          class #{klass} < Arel::Attributes::#{klass}
            include Attributes
          end
        R
      end
    end
  end
end

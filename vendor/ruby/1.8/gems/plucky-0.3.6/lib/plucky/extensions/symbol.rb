# encoding: UTF-8
module Plucky
  module Extensions
    module Symbol
      def gt
        SymbolOperator.new(self, 'gt')
      end

      def lt
        SymbolOperator.new(self, 'lt')
      end

      def gte
        SymbolOperator.new(self, 'gte')
      end

      def lte
        SymbolOperator.new(self, 'lte')
      end

      def ne
        SymbolOperator.new(self, 'ne')
      end

      def in
        SymbolOperator.new(self, 'in')
      end

      def nin
        SymbolOperator.new(self, 'nin')
      end

      def mod
        SymbolOperator.new(self, 'mod')
      end

      def all
        SymbolOperator.new(self, 'all')
      end

      def size
        SymbolOperator.new(self, 'size')
      end unless Symbol.instance_methods.include?(:size) # Ruby 1.9 defines symbol size

      def exists
        SymbolOperator.new(self, 'exists')
      end

      def asc
        SymbolOperator.new(self, 'asc')
      end

      def desc
        SymbolOperator.new(self, 'desc')
      end
    end
  end
end

class SymbolOperator
  include Comparable

  attr_reader :field, :operator

  def initialize(field, operator, options={})
    @field, @operator = field, operator
  end unless method_defined?(:initialize)

  def <=>(other)
    if field == other.field
      operator <=> other.operator
    else
      field.to_s <=> other.field.to_s
    end
  end

  def ==(other)
    field == other.field && operator == other.operator
  end
end

class Symbol
  include Plucky::Extensions::Symbol
end

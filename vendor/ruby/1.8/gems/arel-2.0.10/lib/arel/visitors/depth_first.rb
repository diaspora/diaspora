module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      def initialize block = nil
        @block = block || Proc.new
      end

      private

      def visit o
        super
        @block.call o
      end

      def unary o
        visit o.expr
      end
      alias :visit_Arel_Nodes_Group             :unary
      alias :visit_Arel_Nodes_Grouping          :unary
      alias :visit_Arel_Nodes_Having            :unary
      alias :visit_Arel_Nodes_Limit             :unary
      alias :visit_Arel_Nodes_Not               :unary
      alias :visit_Arel_Nodes_Offset            :unary
      alias :visit_Arel_Nodes_On                :unary
      alias :visit_Arel_Nodes_Top               :unary
      alias :visit_Arel_Nodes_UnqualifiedColumn :unary

      def function o
        visit o.expressions
        visit o.alias
      end
      alias :visit_Arel_Nodes_Avg    :function
      alias :visit_Arel_Nodes_Exists :function
      alias :visit_Arel_Nodes_Max    :function
      alias :visit_Arel_Nodes_Min    :function
      alias :visit_Arel_Nodes_Sum    :function

      def visit_Arel_Nodes_Count o
        visit o.expressions
        visit o.alias
        visit o.distinct
      end

      def join o
        visit o.left
        visit o.right
        visit o.constraint
      end
      alias :visit_Arel_Nodes_InnerJoin :join
      alias :visit_Arel_Nodes_OuterJoin :join

      def binary o
        visit o.left
        visit o.right
      end
      alias :visit_Arel_Nodes_And                :binary
      alias :visit_Arel_Nodes_As                 :binary
      alias :visit_Arel_Nodes_Assignment         :binary
      alias :visit_Arel_Nodes_Between            :binary
      alias :visit_Arel_Nodes_DeleteStatement    :binary
      alias :visit_Arel_Nodes_DoesNotMatch       :binary
      alias :visit_Arel_Nodes_Equality           :binary
      alias :visit_Arel_Nodes_GreaterThan        :binary
      alias :visit_Arel_Nodes_GreaterThanOrEqual :binary
      alias :visit_Arel_Nodes_In                 :binary
      alias :visit_Arel_Nodes_LessThan           :binary
      alias :visit_Arel_Nodes_LessThanOrEqual    :binary
      alias :visit_Arel_Nodes_Matches            :binary
      alias :visit_Arel_Nodes_NotEqual           :binary
      alias :visit_Arel_Nodes_NotIn              :binary
      alias :visit_Arel_Nodes_Or                 :binary
      alias :visit_Arel_Nodes_Ordering           :binary
      alias :visit_Arel_Nodes_StringJoin         :binary
      alias :visit_Arel_Nodes_TableAlias         :binary
      alias :visit_Arel_Nodes_Values             :binary

      def visit_Arel_Attribute o
        visit o.relation
        visit o.name
      end
      alias :visit_Arel_Attributes_Integer :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Float :visit_Arel_Attribute
      alias :visit_Arel_Attributes_String :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Time :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Boolean :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Attribute :visit_Arel_Attribute
      alias :visit_Arel_Attributes_Decimal :visit_Arel_Attribute

      def visit_Arel_Table o
        visit o.name
      end

      def terminal o
      end
      alias :visit_ActiveSupport_Multibyte_Chars :terminal
      alias :visit_ActiveSupport_StringInquirer  :terminal
      alias :visit_Arel_Nodes_Lock               :terminal
      alias :visit_Arel_Nodes_Node               :terminal
      alias :visit_Arel_Nodes_SqlLiteral         :terminal
      alias :visit_Arel_SqlLiteral               :terminal
      alias :visit_BigDecimal                    :terminal
      alias :visit_Bignum                        :terminal
      alias :visit_Class                         :terminal
      alias :visit_Date                          :terminal
      alias :visit_DateTime                      :terminal
      alias :visit_FalseClass                    :terminal
      alias :visit_Fixnum                        :terminal
      alias :visit_Float                         :terminal
      alias :visit_NilClass                      :terminal
      alias :visit_String                        :terminal
      alias :visit_Symbol                        :terminal
      alias :visit_Time                          :terminal
      alias :visit_TrueClass                     :terminal

      def visit_Arel_Nodes_InsertStatement o
        visit o.relation
        visit o.columns
        visit o.values
      end

      def visit_Arel_Nodes_SelectCore o
        visit o.projections
        visit o.froms
        visit o.wheres
        visit o.groups
        visit o.having
      end

      def visit_Arel_Nodes_SelectStatement o
        visit o.cores
        visit o.orders
        visit o.limit
        visit o.lock
        visit o.offset
      end

      def visit_Arel_Nodes_UpdateStatement o
        visit o.relation
        visit o.values
        visit o.wheres
        visit o.orders
        visit o.limit
      end

      def visit_Array o
        o.each { |i| visit i }
      end

      def visit_Hash o
        o.each { |k,v| visit(k); visit(v) }
      end
    end
  end
end

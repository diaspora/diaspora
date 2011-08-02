module Arel
  module SqlCompiler
    class Mysql2Compiler < GenericCompiler
      def limited_update_conditions(conditions, taken)
        conditions << " LIMIT #{taken}"
        conditions
      end
    end
  end
end


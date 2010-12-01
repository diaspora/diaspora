module Cucumber
  module Ast
    class Visitor
      DEPRECATION_WARNING = "Cucumber::Ast::Visitor is deprecated and will be removed. You no longer need to inherit from this class."

      def initialize(step_mother)
        raise(DEPRECATION_WARNING)
      end
    end
  end
end

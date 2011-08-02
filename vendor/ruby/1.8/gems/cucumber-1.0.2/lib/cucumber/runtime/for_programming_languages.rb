require 'forwardable'

module Cucumber
  class Runtime
    # This is what a programming language will consider to be a runtime.
    # 
    # It's a thin class that directs the handul of methods needed by the
    # programming languages to the right place.
    class ForProgrammingLanguages
      extend Forwardable
    
      def initialize(support_code, user_interface)
        @support_code, @user_interface = support_code, user_interface
      end

      def_delegators :@user_interface,
        :embed,
        :ask,
        :puts,
        :features_paths,
        :step_match
    
      def_delegators :@support_code,
        :invoke_steps,
        :invoke,
        :load_programming_language
    
      # Returns a Cucumber::Ast::Table for +text_or_table+, which can either
      # be a String:
      #
      #   table(%{
      #     | account | description | amount |
      #     | INT-100 | Taxi        | 114    |
      #     | CUC-101 | Peeler      | 22     |
      #   })
      #
      # or a 2D Array:
      #
      #   table([
      #     %w{ account description amount },
      #     %w{ INT-100 Taxi        114    },
      #     %w{ CUC-101 Peeler      22     }
      #   ])
      #
      def table(text_or_table, file=nil, line_offset=0)
        if Array === text_or_table
          Ast::Table.new(text_or_table)
        else
          Ast::Table.parse(text_or_table, file, line_offset)
        end
      end

      # Returns a regular String for +string_with_triple_quotes+. Example:
      #
      #   """
      #    hello
      #   world
      #   """
      #
      # Is retured as: " hello\nworld"
      #
      def doc_string(string_with_triple_quotes, file=nil, line_offset=0)
        Ast::DocString.parse(string_with_triple_quotes)
      end
    end
  end
end
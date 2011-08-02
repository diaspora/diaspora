module Debugger

  require 'pp'
  require 'nodepp'
  require 'classtree'
  require 'parse_tree'
  class Disassemble < Command # :nodoc:
    self.allow_in_control = false
    @@parse_tree = ParseTree.new(true)
    
    def regexp
      /^\s*(dis(?:assemble)?)\s+/
    end

    def execute
      expr = @match ? @match.post_match : @input
      binding = @state.context ? get_binding : TOPLEVEL_BINDING
      method_str = "method(:#{expr})"
      if method_obj = debug_eval(method_str, binding)
        print @@parse_tree.parse_tree_for_method(method_obj.class, 
                                                 method_str).inspect
        print "#{method_obj}\n"
      end
    end

    class << self
      def help_command
        %w|disassemble method-name|
      end

      def help(cmd)
          %{
            dis[assemble] method-name\tdo live unparsing of method name
          }
      end
    end
  end if false
end

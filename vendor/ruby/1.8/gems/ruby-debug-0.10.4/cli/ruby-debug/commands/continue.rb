module Debugger

  # Implements debugger "continue" command.
  class ContinueCommand < Command
    self.allow_in_post_mortem = true
    self.need_context         = false
    def regexp
      /^\s* c(?:ont(?:inue)?)? (?:\s+(.*))? $/x
    end

    def execute
      if @match[1] && !@state.context.dead?
        filename = File.expand_path(@state.file)
        line_number = get_int(@match[1], "Continue", 0, nil, 0)
        return unless line_number
        unless LineCache.trace_line_numbers(filename).member?(line_number)
          errmsg("Line %d is not a stopping point in file \"%s\".\n", 
                 line_number, filename) 
          return
        end
        @state.context.set_breakpoint(filename, line_number)
      end
      @state.proceed
    end

    class << self
      def help_command
        'continue'
      end

      def help(cmd)
        %{
          c[ont[inue]][ nnn]\trun until program ends, hits a breakpoint or reaches line nnn 
        }
      end
    end
  end
end

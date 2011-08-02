module Debugger

  # Implements debugger "continue" command.
  class ContinueCommand < Command
    self.allow_in_post_mortem = false
    self.need_context         = true
    def regexp
      /^\s* c(?:ont(?:inue)?)? (?:\s+(.*))? $/x
    end

    def execute
      unless @state.context
        errmsg "We are not in a state we can continue.\n"
        return 
      end
      if @match[1] && !@state.context.dead?
        if '-' == @match[1]
          Debugger.stop if Debugger.started? 
        else
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
      end
      @state.proceed
    end

    class << self
      def help_command
        'continue'
      end

      def help(cmd)
        %{
          c[ont[inue]][ nnn | -]\trun until program ends, hits a breakpoint or reaches line nnn.

If - is given then we issue a Debugger.stop to remove tracing the program continues at full speed.
        }
      end
    end
  end
end

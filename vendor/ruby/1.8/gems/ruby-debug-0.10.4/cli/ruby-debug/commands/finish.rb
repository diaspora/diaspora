module Debugger
  # Implements the debugger 'finish' command.
  class FinishCommand < Command
    self.allow_in_post_mortem = false
    self.need_context         = true
    
    def regexp
      /^\s*fin(?:ish)? (?:\s+(.*))?$/x
    end

    def execute
      max_frame = @state.context.stack_size - @state.frame_pos
      if !@match[1] or @match[1].empty?
        frame_pos = @state.frame_pos
      else
        frame_pos = get_int(@match[1], "Finish", 0, max_frame-1, 0)
        return nil unless frame_pos
      end
      @state.context.stop_frame = frame_pos
      @state.frame_pos = 0
      @state.proceed
    end

    class << self
      def help_command
        'finish'
      end

      def help(cmd)
        %{
          fin[ish] [frame-number]\tExecute until selected stack frame returns.

If no frame number is given, we run until the currently selected frame
returns.  The currently selected frame starts out the most-recent
frame or 0 if no frame positioning (e.g "up", "down" or "frame") has
been performed. If a frame number is given we run until that frame
returns.
        }
      end
    end
  end
end

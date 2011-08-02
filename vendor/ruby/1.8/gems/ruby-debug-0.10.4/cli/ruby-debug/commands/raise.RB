module Debugger
  class RaiseCommand < Command # :nodoc:
    self.allow_in_control = false

    def regexp
      /^\s* raise
           (?:\s+ (\S+))? \s* $/ix
    end

    def execute
      excn = @match[1]
      exception = 
        if not excn
          # No args given.
          RuntimeError
        else
          unless debug_eval("#{excn}.is_a?(Class)", binding)
            errmsg "#{excn} is not known to be a Class\n"
            return
          end
          debug_eval(excn, binding)
        end
      @state.exception = exception
      @state.proceed
    end

    class << self
      def help_command
        'raise'
      end

      def help(cmd)
        %{
           raise EXCEPTION

          Raise an exception in the debugged program."
        }
      end
    end
  end
end

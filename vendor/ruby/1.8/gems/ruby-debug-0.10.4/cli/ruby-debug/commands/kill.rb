module Debugger

  # Implements debugger "kill" command
  class KillCommand < Command
    self.allow_in_control = true

    def regexp
      / ^\s*
         (?:kill) \s*
         (?:\s+(\S+))?\s*
         $
      /ix
    end

    def execute
      if @match[1] 
        signame = @match[1]
        unless Signal.list.member?(signame)
          errmsg("signal name #{signame} is not a signal I know about\n")
          return false
        end
        if 'KILL' == signame
            @state.interface.finalize
        end
      else
        if not confirm("Really kill? (y/n) ")
          return
        else 
          signame = 'KILL'
        end
      end
      Process.kill(signame, Process.pid)
    end

    class << self
      def help_command
        %w[kill]
      end

      def help(cmd)
        %{
          kill [SIGNAL]

          Send [signal] to Process.pid
Equivalent of Process.kill(Process.pid)
         }
     end
    end
  end
end

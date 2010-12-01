module Debugger
  # Implements debugger "source" command.
  class SourceCommand < Command
    self.allow_in_control = true
    
    def regexp
      /^\s* so(?:urce)? (\s+ -v)? \s+ (.+) $/x
    end
    
    def execute
      if 3 == @match.size then
        verbose=true
        file=@match[2]
      else
        verbose=false
        file=@match[1]
      end
        
      file = File.expand_path(file).strip
      unless File.exist?(file)
        errmsg "Command file '#{file}' is not found\n"
        return
      end
      if @state and @state.interface
        @state.interface.command_queue += File.open(file).readlines
      else
        Debugger.run_script(file, @state, verbose)
      end
    end
    
    class << self
      def help_command
        'source'
      end
      
      def help(cmd)
        %{
          source FILE\texecutes a file containing debugger commands
        }
      end
    end
  end
  
end

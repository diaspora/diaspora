module Debugger

  # Implements debugger "help" command.
  class HelpCommand < Command
    self.allow_in_control = true

    # An input line is matched against this regular expression. If we have
    # a match, run this command.
    def regexp
      /^\s* h(?:elp)? (?:\s+(.+))? $/x
    end

    # The code that implements this command.
    def execute
      if @match[1]
        args = @match[1].split
        cmds = @state.commands.select do |cmd| 
          [cmd.help_command].flatten.include?(args[0])
        end
      else
        args = @match[1]
        cmds = []
      end
      unless cmds.empty?
        help = cmds.map{ |cmd| cmd.help(args) }.join
        help = help.split("\n").map{|l| l.gsub(/^ +/, '')}
        help.shift if help.first && help.first.empty?
        help.pop if help.last && help.last.empty?
        print help.join("\n")
      else
        if args and args[0]
          errmsg "Undefined command: \"#{args[0]}\".  Try \"help\"."
        else
          print "ruby-debug help v#{Debugger::VERSION}\n" unless
            self.class.settings[:debuggertesting]
          print "Type 'help <command-name>' for help on a specific command\n\n"
          print "Available commands:\n"
          cmds = @state.commands.map{ |cmd| cmd.help_command }
          cmds = cmds.flatten.uniq.sort
          print columnize(cmds, self.class.settings[:width])
        end
      end
      print "\n"
    end

    class << self
      # The command name listed via 'help'
      def help_command
        'help'
      end

      # Returns a String given the help description of this command
      def help(cmd)
        %{
          h[elp]\t\tprint this help
          h[elp] command\tprint help on command
        }
      end
    end
  end
end

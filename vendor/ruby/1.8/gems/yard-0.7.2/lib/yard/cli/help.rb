module YARD
  module CLI
    # Handles help for commands
    # @since 0.6.0
    class Help < Command
      def description; "Retrieves help for a command" end

      def run(*args)
        if args.first && cmd = CommandParser.commands[args.first.to_sym]
          cmd.run('--help')
        else
          puts "Command #{args.first} not found." if args.first
          CommandParser.run('--help')
        end
      end
    end
  end
end
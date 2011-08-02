module YARD
  module CLI
    # Lists all constant and method names in the codebase. Uses {Yardoc} --list.
    class List < Command
      def description; 'Lists all constant and methods. Uses `yard doc --list`' end
      
      # Runs the commandline utility, parsing arguments and displaying a
      # list of objects
      #
      # @param [Array<String>] args the list of arguments.
      # @return [void]
      def run(*args)
        if args.include?('--help')
          puts "Usage: yard list [yardoc_options]"
          puts "Takes the same arguments as yardoc. See yardoc --help"
        else
          Yardoc.run('--list', *args)
        end
      end
    end
  end
end
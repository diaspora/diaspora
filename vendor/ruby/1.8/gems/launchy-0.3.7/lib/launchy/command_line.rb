require 'optparse'

module Launchy
  class CommandLine

    def parser
      @parser ||= OptionParser.new do |op|
        op.banner = "Usage: launchy [options] url"
        op.separator ""
        op.on("-d", "--debug", "Force debug, output lots of information.",
                               "This sets the LAUNCHY_DEBUG environment variable to 'true'.") do |d|
          ENV["LAUNCHY_DEBUG"] = 'true'
        end

        op.on("-h", "--help", "Print this message") do |h|
          puts op.to_s
          exit 0
        end

        op.on("-v", "--version", "Output the version of Launchy") do |v|
          puts "Launchy version #{Launchy::VERSION}"
          exit 0
        end

        op.on("-o", "--host-os HOST_OS","Force the behavior of a particular host os.",
                                    "This sets the LAUNCHY_HOST_OS environment variable.") do |os|
          ENV["LAUNCHY_HOST_OS"] = os
        end

        op.on("-b", "--browser BROWSER", "Force launchy to use a particular browser.",
                                   "This sets the LAUNCHY_BROWSER environment variable.") do |browser|
          ENV["LAUNCHY_BROWSER"] = browser
        end
      end
    end

    def run(argv = ARGV)
      begin
        parser.parse!(argv)
        Launchy.open(*argv)
      rescue ::OptionParser::ParseError => pe
        $stderr.puts "#{parser.programn_name}: #{pe}"
        $stderr.puts "Try `#{parser.program_name} --help' for more information."
        exit 1
      end
    end
  end
end

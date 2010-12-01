require 'optparse'
require File.expand_path(File.dirname(__FILE__) + '/../jammit')

module Jammit

  # The @CommandLine@ is able to compress, pre-package, and pre-gzip all the
  # assets specified in the configuration file, in order to avoid an initial
  # round of slow requests after a fresh deployment.
  class CommandLine

    BANNER = <<-EOS

Usage: jammit OPTIONS

Run jammit inside a Rails application to compresses all JS, CSS,
and JST according to config/assets.yml, saving the packaged
files and corresponding gzipped versions.

If you're using "embed_assets", and you wish to precompile the
MHTML stylesheet variants, you must specify the "base-url".

Options:
    EOS

    # The @Jammit::CommandLine@ runs from the contents of @ARGV@.
    def initialize
      parse_options
      ensure_configuration_file
      Jammit.package!(@options)
    end


    private

    # Make sure that we have a readable configuration file. The @jammit@
    # command can't run without one.
    def ensure_configuration_file
      config = @options[:config_path]
      return true if File.exists?(config) && File.readable?(config)
      puts "Could not find the asset configuration file \"#{config}\""
      exit(1)
    end

    # Uses @OptionParser@ to grab the options: *--output*, *--config*, and
    # *--base-url*...
    def parse_options
      @options = {
        :config_path    => Jammit::DEFAULT_CONFIG_PATH,
        :output_folder  => nil,
        :base_url       => nil,
        :force          => false
      }
      @option_parser = OptionParser.new do |opts|
        opts.on('-o', '--output PATH', 'output folder for packages (default: "public/assets")') do |output_folder|
          @options[:output_folder] = output_folder
        end
        opts.on('-c', '--config PATH', 'path to assets.yml (default: "config/assets.yml")') do |config_path|
          @options[:config_path] = config_path
        end
        opts.on('-u', '--base-url URL', 'base URL for MHTML (ex: "http://example.com")') do |base_url|
          @options[:base_url] = base_url
        end
        opts.on('-f', '--force', 'force a rebuild of all assets') do |force|
          @options[:force] = force
        end
        opts.on_tail('-v', '--version', 'display Jammit version') do
          puts "Jammit version #{Jammit::VERSION}"
          exit
        end
      end
      @option_parser.banner = BANNER
      @option_parser.parse!(ARGV)
    end

  end

end
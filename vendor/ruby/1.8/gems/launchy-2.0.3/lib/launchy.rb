require 'uri'

#
# The entry point into Launchy. This is the sole supported public API.
#
#   Launchy.open( uri, options = {} )
#
# The currently defined global options are:
#
#   :debug        Turn on debugging output
#   :application  Explicitly state what application class is going to be used
#   :host_os      Explicitly state what host operating system to pretend to be
#   :ruby_engine  Explicitly state what ruby engine to pretend to be under
#   :dry_run      Do nothing and print the command that would be executed on $stdout
#
# Other options may be used, and those will be passed directly to the
# application class
#
module Launchy

  class << self
    #
    # Convenience method to launch an item
    #
    def open(uri, options = {} )
      begin
        extract_global_options( options )
        uri = URI.parse( uri )
        app = Launchy::Application.for_scheme( uri )
        app.new.open( uri, options )
      rescue Exception => e
        msg = "Failure in opening #{uri} with options #{options.inspect}: #{e}"
        Launchy.log "#{self.name} : #{msg}"
        e.backtrace.each do |bt|
          Launchy.log bt
        end
        $stderr.puts msg
      end
    end

    def reset_global_options
      Launchy.debug       = false
      Launchy.application = nil
      Launchy.host_os     = nil
      Launchy.ruby_engine = nil
      Launchy.dry_run     = false
    end

    def extract_global_options( options )
      Launchy.debug        = options.delete( :debug       ) || ENV['LAUNCHY_DEBUG']
      Launchy.application  = options.delete( :application ) || ENV['LAUNCHY_APPLICATION']
      Launchy.host_os      = options.delete( :host_os     ) || ENV['LAUNCHY_HOST_OS']
      Launchy.ruby_engine  = options.delete( :ruby_engine ) || ENV['LAUNCHY_RUBY_ENGINE']
      Launchy.dry_run      = options.delete( :dry_run     )
    end

    def debug=( d )
      @debug = (d == "true")
    end

    # we may do logging before a call to 'open', hence the need to check
    # LAUNCHY_DEBUG here
    def debug?
      @debug || (ENV['LAUNCHY_DEBUG'] == 'true')
    end

    def application=( app )
      @application = app
    end

    def application
      @application || ENV['LAUNCHY_APPLICATION']
    end

    def host_os=( host_os )
      @host_os = host_os
    end

    def host_os
      @host_os || ENV['LAUNCHY_HOST_OS']
    end

    def ruby_engine=( ruby_engine )
      @ruby_engine = ruby_engine
    end

    def ruby_engine
      @ruby_engine || ENV['LAUNCHY_RUBY_ENGINE']
    end

    def dry_run=( dry_run )
      @dry_run = dry_run
    end

    def dry_run?
      @dry_run
    end

    def bug_report_message
      "Please file a bug at https://github.com/copiousfreetime/launchy/issues/new"
    end

    def log(msg)
      $stderr.puts "LAUNCHY_DEBUG: #{msg}" if Launchy.debug?
    end
  end
end

require 'launchy/version'
require 'launchy/cli'
require 'launchy/descendant_tracker'
require 'launchy/error'
require 'launchy/application'
require 'launchy/detect'
require 'launchy/deprecated'

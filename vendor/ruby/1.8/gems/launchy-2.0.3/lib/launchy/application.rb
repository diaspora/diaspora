require 'set'
module Launchy
  #
  # Application is the base class of all the application types that launchy may
  # invoke. It essentially defines the public api of the launchy system.
  #
  # Every class that inherits from Application must define:
  #
  # 1. A constructor taking no parameters
  # 2. An instance method 'open' taking a string or URI as the first parameter and a
  #    hash as the second
  # 3. A class method 'schemes' that returns an array of Strings containing the
  #    schemes that the Application will handle
  class Application
    extend DescendantTracker

    class << self
      #
      # The list of all the schemes all the applications know
      #
      def scheme_list
        children.collect { |a| a.schemes }.flatten.sort
      end

      #
      # if this application handles the given scheme
      #
      def handles?( scheme )
        schemes.include?( scheme )
      end

      #
      # Find the application that handles the given scheme.  May take either a
      # String or something that responds_to?( :scheme )
      #
      def for_scheme( scheme )
        if scheme.respond_to?( :scheme ) then
          scheme = scheme.scheme
        end

        klass = find_child( :handles?, scheme )
        return klass if klass

        raise SchemeNotFoundError, "No application found to handle scheme '#{scheme}'. Known schemes: #{scheme_list.join(", ")}"
      end

      #
      # Find the given executable in the available paths
      def find_executable( bin, *paths )
        paths = ENV['PATH'].split( File::PATH_SEPARATOR ) if paths.empty?
        paths.each do |path|
          file = File.join( path, bin )
          if File.executable?( file ) then
            Launchy.log "#{self.name} : found executable #{file}"
            return file
          end
        end
        Launchy.log "#{self.name} : Unable to find `#{bin}' in #{paths.join(", ")}"
        return nil
      end
    end

    attr_reader :host_os_family
    attr_reader :ruby_engine
    attr_reader :runner

    def initialize
      @host_os_family = Launchy::Detect::HostOsFamily.detect
      @ruby_engine    = Launchy::Detect::RubyEngine.detect
      @runner         = Launchy::Detect::Runner.detect
    end

    def find_executable( bin, *paths )
      Application.find_executable( bin, *paths )
    end

    def run( cmd, *args )
      runner.run( cmd, *args )
    end
  end
end
require 'launchy/applications/browser'

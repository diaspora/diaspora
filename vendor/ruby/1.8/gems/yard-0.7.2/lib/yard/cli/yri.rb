require 'rbconfig'

module YARD
  module CLI
    # A tool to view documentation in the console like `ri`
    class YRI < Command
      # The location in {YARD::CONFIG_DIR} where the YRI cache file is loaded
      # from.
      CACHE_FILE = File.expand_path('~/.yard/yri_cache')

      # A file containing all paths, delimited by newlines, to search for
      # yardoc databases.
      # @since 0.5.1
      SEARCH_PATHS_FILE = File.expand_path('~/.yard/yri_search_paths')

      # Default search paths that should be loaded dynamically into YRI. These paths
      # take precedence over all other paths ({SEARCH_PATHS_FILE} and RubyGems
      # paths). To add a path, call:
      #
      #   DEFAULT_SEARCH_PATHS.push("/path/to/.yardoc")
      #
      # @return [Array<String>] a list of extra search paths
      # @since 0.6.0
      DEFAULT_SEARCH_PATHS = []

      # Helper method to run the utility on an instance.
      # @see #run
      def self.run(*args) new.run(*args) end

      def initialize
        super
        @cache = {}
        @search_paths = []
        add_default_paths
        add_gem_paths
        load_cache
        @search_paths.uniq!
      end

      def description
        "A tool to view documentation in the console like `ri`"
      end

      # Runs the command-line utility.
      #
      # @example
      #   YRI.new.run('String#reverse')
      # @param [Array<String>] args each tokenized argument
      def run(*args)
        optparse(*args)

        if ::Config::CONFIG['host_os'] =~ /mingw|win32/
          @serializer ||= YARD::Serializers::StdoutSerializer.new
        else
          @serializer ||= YARD::Serializers::ProcessSerializer.new('less')
        end

        if @name.nil? || @name.strip.empty?
          print_usage
          exit(1)
        elsif object = find_object(@name)
          print_object(object)
        else
          STDERR.puts "No documentation for `#{@name}'"
          exit(1)
        end
      end

      protected

      # Prints the command usage
      # @return [void]
      # @since 0.5.6
      def print_usage
        puts "Usage: yri [options] <Path to object>"
        puts "See yri --help for more options."
      end

      # Caches the .yardoc file where an object can be found in the {CACHE_FILE}
      # @return [void]
      def cache_object(name, path)
        return if path == Registry.yardoc_file
        @cache[name] = path

        File.open!(CACHE_FILE, 'w') do |file|
          @cache.each do |key, value|
            file.puts("#{key} #{value}")
          end
        end
      end

      # @param [CodeObjects::Base] object the object to print.
      # @return [String] the formatted output for an object.
      def print_object(object)
        if object.type == :method && object.is_alias?
          tmp = P(object.namespace, (object.scope == :instance ? "#" : "") +
            object.namespace.aliases[object].to_s)
          object = tmp unless YARD::CodeObjects::Proxy === tmp
        end
        object.format(:serializer => @serializer)
      end

      # Locates an object by name starting in the cached paths and then
      # searching through any search paths.
      #
      # @param [String] name the full name of the object
      # @return [CodeObjects::Base] an object if found
      # @return [nil] if no object is found
      def find_object(name)
        @search_paths.unshift(@cache[name]) if @cache[name]
        @search_paths.unshift(Registry.yardoc_file)

        log.debug "Searching for #{name} in search paths"
        @search_paths.each do |path|
          next unless File.exist?(path)
          log.debug "Searching for #{name} in #{path}..."
          Registry.load(path)
          obj = Registry.at(name)
          if obj
            cache_object(name, path)
            return obj
          end
        end
        nil
      end

      private

      # Loads {CACHE_FILE}
      # @return [void]
      def load_cache
        return unless File.file?(CACHE_FILE)
        File.readlines(CACHE_FILE).each do |line|
          line = line.strip.split(/\s+/)
          @cache[line[0]] = line[1]
        end
      end

      # Adds all RubyGems yardoc files to search paths
      # @return [void]
      def add_gem_paths
        require 'rubygems'
        gem_paths = []
        Gem.source_index.find_name('').each do |spec|
          if yfile = Registry.yardoc_file_for_gem(spec.name)
            if spec.name =~ /^yard-doc-/
              gem_paths.unshift(yfile)
            else
              gem_paths.push(yfile)
            end
          end
        end
        @search_paths += gem_paths
      rescue LoadError
      end

      # Adds paths in {SEARCH_PATHS_FILE}
      # @since 0.5.1
      def add_default_paths
        @search_paths.push(*DEFAULT_SEARCH_PATHS)
        return unless File.file?(SEARCH_PATHS_FILE)
        paths = File.readlines(SEARCH_PATHS_FILE).map {|l| l.strip }
        @search_paths.push(*paths)
      end

      # Parses commandline options.
      # @param [Array<String>] args each tokenized argument
      def optparse(*args)
        opts = OptionParser.new
        opts.banner = "Usage: yri [options] <Path to object>"
        opts.separator "Example: yri String#gsub"
        opts.separator ""
        opts.separator "General Options:"

        opts.on('-b', '--db FILE', 'Use a specified .yardoc db to search in') do |yfile|
          @search_paths.unshift(yfile)
        end

        opts.on('-T', '--no-pager', 'No pager') do
          @serializer = YARD::Serializers::StdoutSerializer.new
        end

        opts.on('-p PAGER', '--pager') do |pager|
          @serializer = YARD::Serializers::ProcessSerializer.new(pager)
        end

        common_options(opts)
        parse_options(opts, args)
        @name = args.first
      end
    end
  end
end

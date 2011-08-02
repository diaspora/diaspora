require 'digest/sha1'
require 'fileutils'

module YARD
  module CLI
    # Yardoc is the default YARD CLI command (+yard doc+ and historic +yardoc+
    # executable) used to generate and output (mainly) HTML documentation given
    # a set of source files.
    #
    # == Usage
    #
    # Main usage for this command is:
    #
    #   $ yardoc [options] [source_files [- extra_files]]
    #
    # See +yardoc --help+ for details on valid options.
    #
    # == Options File (+.yardopts+)
    #
    # If a +.yardopts+ file is found in the source directory being processed,
    # YARD will use the contents of the file as arguments to the command,
    # treating newlines as spaces. You can use shell-style quotations to
    # group space delimited arguments, just like on the command line.
    #
    # A valid +.yardopts+ file might look like:
    #
    #   --no-private
    #   --title "My Title"
    #   --exclude foo --exclude bar
    #   lib/**/*.erb
    #   lib/**/*.rb -
    #   HACKING.rdoc LEGAL COPYRIGHT
    #
    # Note that Yardoc also supports the legacy RDoc style +.document+ file,
    # though this file can only specify source globs to parse, not options.
    #
    # == Queries (+--query+)
    #
    # Yardoc supports queries to select specific code objects for which to
    # generate documentation. For example, you might want to generate
    # documentation only for your public API. If you've documented your public
    # methods with +@api public+, you can use the following query to select
    # all of these objects:
    #
    #   --query '@api.text == "public"'
    #
    # Note that the syntax for queries is mostly Ruby with a few syntactic
    # simplifications for meta-data tags. See the {Verifier} class for an
    # overview of this syntax.
    #
    # == Adding Custom Ad-Hoc Meta-data Tags (+--tag+)
    #
    # YARD allows specification of {file:docs/Tags.md meta-data tags}
    # programmatically via the {YARD::Tags::Library} class, but often this is not
    # practical for users writing documentation. To make adding custom tags
    # easier, Yardoc has a few command-line switches for creating basic tags
    # and displaying them in generated HTML output.
    #
    # To specify a custom tag to be displayed in output, use any of the
    # following:
    #
    # * +--tag+ TAG:TITLE
    # * +--name-tag+ TAG:TITLE
    # * +--type-tag+ TAG:TITLE
    # * +--type-name-tag+ TAG:TITLE
    # * +--title-tag+ TAG:TITLE
    #
    # "TAG:TITLE" is of the form: name:"Display Title", for example:
    #
    #   --tag overload:"Overloaded Method"
    #
    # See +yardoc --help+ for a description of the various options.
    #
    # Tags added in this way are automatically displayed in output. To add
    # a meta-data tag that does not show up in output, use +--hide-tag TAG+.
    # Note that you can also use this option on existing tags to hide
    # builtin tags, for instance.
    #
    # == Processed Data Storage (+.yardoc+ directory)
    #
    # When Yardoc parses a source directory, it creates a +.yardoc+ directory
    # (by default, override with +-b+) at the root of the project. This directory
    # contains marshal dumps for all raw object data in the source, so that
    # you can access it later for various commands (+stats+, +graph+, etc.).
    # This directory is also used as a cache for any future calls to +yardoc+
    # so as to process only the files which have changed since the last call.
    #
    # When Yardoc uses the cache in subsequent calls to +yardoc+, methods
    # or classes that have been deleted from source since the last parsing
    # will not be erased from the cache (YARD never deletes objects). In such
    # a case, you should wipe the cache and do a clean parsing of the source tree.
    # You can do this by deleting the +.yardoc+ directory manually, or running
    # Yardoc without +--use-cache+ (+-c+).
    #
    # @since 0.2.1
    # @see Verifier
    class Yardoc < Command
      # The configuration filename to load extra options from
      DEFAULT_YARDOPTS_FILE = ".yardopts"

      # @return [Hash] the hash of options passed to the template.
      # @see Templates::Engine#render
      attr_reader :options

      # @return [Array<String>] list of Ruby source files to process
      attr_accessor :files

      # @return [Array<String>] list of excluded paths (regexp matches)
      # @since 0.5.3
      attr_accessor :excluded

      # @return [Boolean] whether to use the existing yardoc db if the
      #   .yardoc already exists. Also makes use of file checksums to
      #   parse only changed files.
      attr_accessor :use_cache

      # @return [Boolean] whether to parse options from .yardopts
      attr_accessor :use_yardopts_file

      # @return [Boolean] whether to parse options from .document
      attr_accessor :use_document_file

      # @return [Boolean] whether objects should be serialized to .yardoc db
      attr_accessor :save_yardoc

      # @return [Boolean] whether to generate output
      attr_accessor :generate

      # @return [Boolean] whether to print a list of objects
      # @since 0.5.5
      attr_accessor :list

      # The options file name (defaults to {DEFAULT_YARDOPTS_FILE})
      # @return [String] the filename to load extra options from
      attr_accessor :options_file

      # Keep track of which visibilities are to be shown
      # @return [Array<Symbol>] a list of visibilities
      # @since 0.5.6
      attr_accessor :visibilities

      # @return [Array<Symbol>] a list of tags to hide from templates
      # @since 0.6.0
      attr_accessor :hidden_tags

      # @return [Boolean] whether to print statistics after parsing
      # @since 0.6.0
      attr_accessor :statistics

      # @return [Array<String>] a list of assets to copy after generation
      # @since 0.6.0
      attr_accessor :assets
      
      # @return [Boolean] whether markup option was specified
      # @since 0.7.0
      attr_accessor :has_markup

      # Creates a new instance of the commandline utility
      def initialize
        super
        @options = SymbolHash.new(false)
        @options.update(
          :format => :html,
          :template => :default,
          :markup => :rdoc, # default is :rdoc but falls back on :none
          :serializer => YARD::Serializers::FileSystemSerializer.new,
          :default_return => "Object",
          :hide_void_return => false,
          :no_highlight => false,
          :files => [],
          :title => "Documentation by YARD #{YARD::VERSION}",
          :verifier => Verifier.new
        )
        @visibilities = [:public]
        @assets = {}
        @excluded = []
        @files = []
        @hidden_tags = []
        @use_cache = false
        @use_yardopts_file = true
        @use_document_file = true
        @generate = true
        @options_file = DEFAULT_YARDOPTS_FILE
        @statistics = true
        @list = false
        @save_yardoc = true
        @has_markup = false

        if defined?(::Encoding) && ::Encoding.respond_to?(:default_external=)
          ::Encoding.default_external, ::Encoding.default_internal = 'utf-8', 'utf-8'
        end
      end

      def description
        "Generates documentation"
      end

      # Runs the commandline utility, parsing arguments and generating
      # output if set.
      #
      # @param [Array<String>] args the list of arguments. If the list only
      #   contains a single nil value, skip calling of {#parse_arguments}
      # @return [void]
      def run(*args)
        if args.size == 0 || !args.first.nil?
          # fail early if arguments are not valid
          return unless parse_arguments(*args)
        end

        checksums = nil
        if use_cache
          Registry.load
          checksums = Registry.checksums.dup
        end
        YARD.parse(files, excluded)
        Registry.save(use_cache) if save_yardoc

        if generate
          run_generate(checksums)
          copy_assets
        elsif list
          print_list
        end

        if !list && statistics && log.level < Logger::ERROR
          Registry.load_all
          log.enter_level(Logger::ERROR) do
            Stats.new(false).run(*args)
          end
        end

        true
      end

      # Parses commandline arguments
      # @param [Array<String>] args the list of arguments
      # @return [Boolean] whether or not arguments are valid
      # @since 0.5.6
      def parse_arguments(*args)
        parse_yardopts_options(*args)

        # Parse files and then command line arguments
        optparse(*support_rdoc_document_file!) if use_document_file
        optparse(*yardopts) if use_yardopts_file
        optparse(*args)

        # Last minute modifications
        self.files = ['{lib,app}/**/*.rb', 'ext/**/*.c'] if self.files.empty?
        self.files.delete_if {|x| x =~ /\A\s*\Z/ } # remove empty ones
        readme = Dir.glob('README*').first
        readme ||= Dir.glob(files.first).first if options[:onefile]
        options[:readme] ||= CodeObjects::ExtraFileObject.new(readme) if readme
        options[:files].unshift(options[:readme]).uniq! if options[:readme]

        Tags::Library.visible_tags -= hidden_tags
        add_visibility_verifier

        if generate && !verify_markup_options
          false
        else
          true
        end
      end

      # The list of all objects to process. Override this method to change
      # which objects YARD should generate documentation for.
      #
      # @deprecated To hide methods use the +@private+ tag instead.
      # @return [Array<CodeObjects::Base>] a list of code objects to process
      def all_objects
        Registry.all(:root, :module, :class)
      end

      # Parses the .yardopts file for default yard options
      # @return [Array<String>] an array of options parsed from .yardopts
      def yardopts
        return [] unless use_yardopts_file
        File.read_binary(options_file).shell_split
      rescue Errno::ENOENT
        []
      end

      private

      # Generates output for objects
      # @param [Hash, nil] checksums if supplied, a list of checkums for files.
      # @return [void]
      # @since 0.5.1
      def run_generate(checksums)
        if checksums
          changed_files = []
          Registry.checksums.each do |file, hash|
            changed_files << file if checksums[file] != hash
          end
        end
        Registry.load_all if use_cache
        objects = run_verifier(all_objects).reject do |object|
          serialized = !options[:serializer] || options[:serializer].exists?(object)
          if checksums && serialized && !object.files.any? {|f, line| changed_files.include?(f) }
            true
          else
            log.info "Re-generating object #{object.path}..."
            false
          end
        end
        Templates::Engine.generate(objects, options)
      end

      # Verifies that the markup options are valid before parsing any code.
      # Failing early is better than failing late.
      #
      # @return (see YARD::Templates::Helpers::MarkupHelper#load_markup_provider)
      def verify_markup_options
        options[:markup] = :rdoc unless has_markup
        result, lvl = false, has_markup ? log.level : Logger::FATAL
        obj = Struct.new(:options).new(options)
        obj.extend(Templates::Helpers::MarkupHelper)
        log.enter_level(lvl) { result = obj.load_markup_provider }
        if !result && !has_markup
          log.warn "Could not load default RDoc formatter, " +
            "ignoring any markup (install RDoc to get default formatting)."
          options[:markup] = :none
          true
        else
          result
        end
      end

      # Copies any assets to the output directory
      # @return [void]
      # @since 0.6.0
      def copy_assets
        return unless options[:serializer]
        outpath = options[:serializer].basepath
        assets.each do |from, to|
          to = File.join(outpath, to)
          log.debug "Copying asset '#{from}' to '#{to}'"
          FileUtils.cp_r(from, to)
        end
      end

      # Prints a list of all objects
      # @return [void]
      # @since 0.5.5
      def print_list
        Registry.load_all
        run_verifier(Registry.all).
          sort_by {|item| [item.file || '', item.line || 0] }.each do |item|
          puts "#{item.file}:#{item.line}: #{item.path}"
        end
      end
      
      # Parses out the yardopts/document options
      def parse_yardopts_options(*args)
        opts = OptionParser.new
        opts.base.long.clear # HACK: why are --help and --version defined?
        yardopts_options(opts)
        begin
          opts.parse(args)
        rescue OptionParser::ParseError => err
          idx = args.index(err.args.first)
          args = args[(idx+1)..-1]
          args.shift while args.first && args.first[0,1] != '-'
          retry
        end
      end

      # Reads a .document file in the directory to get source file globs
      # @return [Array<String>] an array of files parsed from .document
      def support_rdoc_document_file!
        return [] unless use_document_file
        File.read(".document").gsub(/^[ \t]*#.+/m, '').split(/\s+/)
      rescue Errno::ENOENT
        []
      end

      # Adds a set of extra documentation files to be processed
      # @param [Array<String>] files the set of documentation files
      def add_extra_files(*files)
        files.map! {|f| f.include?("*") ? Dir.glob(f) : f }.flatten!
        files.each do |file|
          if File.file?(file)
            options[:files] << CodeObjects::ExtraFileObject.new(file)
          else
            log.warn "Could not find extra file: #{file}"
          end
        end
      end

      # Parses the file arguments into Ruby files and extra files, which are
      # separated by a '-' element.
      #
      # @example Parses a set of Ruby source files
      #   parse_files %w(file1 file2 file3)
      # @example Parses a set of Ruby files with a separator and extra files
      #   parse_files %w(file1 file2 - extrafile1 extrafile2)
      # @param [Array<String>] files the list of files to parse
      # @return [void]
      def parse_files(*files)
        seen_extra_files_marker = false

        files.each do |file|
          if file == "-"
            seen_extra_files_marker = true
            next
          end

          if seen_extra_files_marker
            add_extra_files(file)
          else
            self.files << file
          end
        end
      end

      # Adds verifier rule for visibilities
      # @return [void]
      # @since 0.5.6
      def add_visibility_verifier
        vis_expr = "object.type != :method || #{visibilities.uniq.inspect}.include?(object.visibility)"
        options[:verifier].add_expressions(vis_expr)
      end

      # (see Templates::Helpers::BaseHelper#run_verifier)
      def run_verifier(list)
        options[:verifier] ? options[:verifier].run(list) : list
      end

      # @since 0.6.0
      def add_tag(tag_data, factory_method = nil)
        tag, title = *tag_data.split(':')
        title ||= tag.capitalize
        Tags::Library.define_tag(title, tag.to_sym, factory_method)
        Tags::Library.visible_tags |= [tag.to_sym]
      end

      # Parses commandline options.
      # @param [Array<String>] args each tokenized argument
      def optparse(*args)
        opts = OptionParser.new
        opts.banner = "Usage: yard doc [options] [source_files [- extra_files]]"

        opts.separator "(if a list of source files is omitted, "
        opts.separator "  {lib,app}/**/*.rb ext/**/*.c is used.)"
        opts.separator ""
        opts.separator "Example: yardoc -o documentation/ - FAQ LICENSE"
        opts.separator "  The above example outputs documentation for files in"
        opts.separator "  lib/**/*.rb to documentation/ including the extra files"
        opts.separator "  FAQ and LICENSE."
        opts.separator ""
        opts.separator "A base set of options can be specified by adding a .yardopts"
        opts.separator "file to your base path containing all extra options separated"
        opts.separator "by whitespace."

        general_options(opts)
        output_options(opts)
        tag_options(opts)
        common_options(opts)
        parse_options(opts, args)
        parse_files(*args) unless args.empty?
      end

      # Adds general options
      def general_options(opts)
        opts.separator ""
        opts.separator "General Options:"

        opts.on('-b', '--db FILE', 'Use a specified .yardoc db to load from or save to',
                      '  (defaults to .yardoc)') do |yfile|
          YARD::Registry.yardoc_file = yfile
        end

        opts.on('--[no-]single-db', 'Whether code objects should be stored to single',
                                    '  database file (advanced)') do |use_single_db|
          Registry.single_object_db = use_single_db
        end

        opts.on('-n', '--no-output', 'Only generate .yardoc database, no documentation.') do
          self.generate = false
        end

        opts.on('-c', '--use-cache [FILE]',
                "Use the cached .yardoc db to generate documentation.",
                "  (defaults to no cache)") do |file|
          YARD::Registry.yardoc_file = file if file
          self.use_cache = true
        end

        opts.on('--no-cache', "Clear .yardoc db before parsing source.") do
          self.use_cache = false
        end

        yardopts_options(opts)

        opts.on('--no-save', 'Do not save the parsed data to the yardoc db') do
          self.save_yardoc = false
        end

        opts.on('--exclude REGEXP', 'Ignores a file if it matches path match (regexp)') do |path|
          self.excluded << path
        end
      end
      
      # Adds --[no-]yardopts / --[no-]document
      def yardopts_options(opts)
        opts.on('--[no-]yardopts [FILE]', 
                "If arguments should be read from FILE",
                "  (defaults to yes, FILE defaults to .yardopts)") do |use_yardopts|
          if use_yardopts.is_a?(String)
            self.options_file = use_yardopts
            self.use_yardopts_file = true
          else
            self.use_yardopts_file = (use_yardopts != false)
          end
        end

        opts.on('--[no-]document', "If arguments should be read from .document file. ",
                                   "  (defaults to yes)") do |use_document|
          self.use_document_file = use_document
        end
      end

      # Adds output options
      def output_options(opts)
        opts.separator ""
        opts.separator "Output options:"

        opts.on('--one-file', 'Generates output as a single file') do
          options[:onefile] = true
        end

        opts.on('--list', 'List objects to standard out (implies -n)') do |format|
          self.generate = false
          self.list = true
        end

        opts.on('--no-public', "Don't show public methods. (default shows public)") do
          visibilities.delete(:public)
        end

        opts.on('--protected', "Show protected methods. (default hides protected)") do
          visibilities.push(:protected)
        end

        opts.on('--private', "Show private methods. (default hides private)") do
          visibilities.push(:private)
        end

        opts.on('--no-private', "Hide objects with @private tag") do
          options[:verifier].add_expressions '!object.tag(:private) &&
            (object.namespace.is_a?(CodeObjects::Proxy) || !object.namespace.tag(:private))'
        end

        opts.on('--no-highlight', "Don't highlight code blocks in output.") do
          options[:no_highlight] = true
        end

        opts.on('--default-return TYPE', "Shown if method has no return type. ",
                                         "  (defaults to 'Object')") do |type|
          options[:default_return] = type
        end

        opts.on('--hide-void-return', "Hides return types specified as 'void'. ",
                                      "  (default is shown)") do
          options[:hide_void_return] = true
        end

        opts.on('--query QUERY', "Only show objects that match a specific query") do |query|
          next if YARD::Config.options[:safe_mode]
          options[:verifier].add_expressions(query.taint)
        end

        opts.on('--title TITLE', 'Add a specific title to HTML documents') do |title|
          options[:title] = title
        end

        opts.on('-r', '--readme FILE', '--main FILE', 'The readme file used as the title page',
                                                      '  of documentation.') do |readme|
          if File.file?(readme)
            options[:readme] = CodeObjects::ExtraFileObject.new(readme)
          else
            log.warn "Could not find readme file: #{readme}"
          end
        end

        opts.on('--files FILE1,FILE2,...', 'Any extra comma separated static files to be ',
                                           '  included (eg. FAQ)') do |files|
          add_extra_files(*files.split(","))
        end

        opts.on('--asset FROM[:TO]', 'A file or directory to copy over to output ',
                                     '  directory after generating') do |asset|
          re = /^(?:\.\.\/|\/)/
          from, to = *asset.split(':').map {|f| File.cleanpath(f) }
          to ||= from
          if from =~ re || to =~ re
            log.warn "Invalid file '#{asset}'"
          else
            assets[from] = to
          end
        end

        opts.on('-o', '--output-dir PATH',
                'The output directory. (defaults to ./doc)') do |dir|
          options[:serializer].basepath = dir
        end

        opts.on('-m', '--markup MARKUP',
                'Markup style used in documentation, like textile, ',
                '  markdown or rdoc. (defaults to rdoc)') do |markup|
          self.has_markup = true
          options[:markup] = markup.to_sym
        end

        opts.on('-M', '--markup-provider MARKUP_PROVIDER',
                'Overrides the library used to process markup ', 
                '  formatting (specify the gem name)') do |markup_provider|
          options[:markup_provider] = markup_provider.to_sym
        end

        opts.on('--charset ENC', 'Character set to use when parsing files ', 
                                 '  (default is system locale)') do |encoding|
          begin
            if defined?(Encoding) && Encoding.respond_to?(:default_external=)
              Encoding.default_external, Encoding.default_internal = encoding, encoding
            end
          rescue ArgumentError => e
            raise OptionParser::InvalidOption, e
          end
        end

        opts.on('-t', '--template TEMPLATE',
                'The template to use. (defaults to "default")') do |template|
          options[:template] = template.to_sym
        end

        opts.on('-p', '--template-path PATH',
                'The template path to look for templates in.',
                '  (used with -t).') do |path|
          next if YARD::Config.options[:safe_mode]
          YARD::Templates::Engine.register_template_path(path)
        end

        opts.on('-f', '--format FORMAT',
                'The output format for the template.',
                '  (defaults to html)') do |format|
          options[:format] = format.to_sym
        end

        opts.on('--no-stats', 'Don\'t print statistics') do
          self.statistics = false
        end
      end

      # Adds tag options
      # @since 0.6.0
      def tag_options(opts)
        opts.separator ""
        opts.separator "Tag options: (TAG:TITLE looks like: 'overload:Overloaded Method')"

        opts.on('--tag TAG:TITLE', 'Registers a new free-form metadata @tag') do |tag|
          add_tag(tag)
        end

        opts.on('--type-tag TAG:TITLE', 'Tag with an optional types field') do |tag|
          add_tag(tag, :with_types)
        end

        opts.on('--type-name-tag TAG:TITLE', 'Tag with optional types and a name field') do |tag|
          add_tag(tag, :with_types_and_name)
        end

        opts.on('--name-tag TAG:TITLE', 'Tag with a name field') do |tag|
          add_tag(tag, :with_name)
        end

        opts.on('--title-tag TAG:TITLE', 'Tag with first line as title field') do |tag|
          add_tag(tag, :with_title_and_text)
        end

        opts.on('--hide-tag TAG', 'Hides a previously defined tag from templates') do |tag|
          self.hidden_tags |= [tag.to_sym]
        end

        opts.on('--transitive-tag TAG', 'Adds a transitive tag') do |tag|
          Tags::Library.transitive_tags += [tag.to_sym]
        end
      end
    end
  end
end

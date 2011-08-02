require 'stringio'
require 'ostruct'

begin require 'continuation'; rescue LoadError; end

module YARD
  module Parser
    # Raised when an object is recognized but cannot be documented. This
    # generally occurs when the Ruby syntax used to declare an object is
    # too dynamic in nature.
    class UndocumentableError < Exception; end

    # Raised when the parser sees a Ruby syntax error
    class ParserSyntaxError < UndocumentableError; end

    # A LoadOrderError occurs when a handler needs to modify a
    # {CodeObjects::NamespaceObject} (usually by adding a child to it)
    # that has not yet been resolved.
    #
    # @see Handers::Base#ensure_loaded!
    class LoadOrderError < Exception; end

    # Responsible for parsing a source file into the namespace. Parsing
    # also invokes handlers to process the parsed statements and generate
    # any code objects that may be recognized.
    #
    # == Custom Parsers
    # SourceParser allows custom parsers to be registered and called when
    # a certain filetype is recognized. To register a parser and hook it
    # up to a set of file extensions, call {register_parser_type}
    #
    # @see register_parser_type
    # @see Handlers::Base
    # @see CodeObjects::Base
    class SourceParser
      SHEBANG_LINE  = /\A\s*#!\S+/
      ENCODING_LINE = /\A(?:\s*#*!.*\r?\n)?\s*#+.*coding\s*[:=]{1,2}\s*(\S+)/i
      
      # Byte order marks for various encodings
      # @since 0.7.0
      ENCODING_BYTE_ORDER_MARKS = {
        'utf-8' => "\xEF\xBB\xBF",
        # Not yet supported
        #'utf-16be' => "\xFE\xFF",
        #'utf-16le' => "\xFF\xFE",
        #'utf-32be' => "\x00\x00\xFF\xFE",
        #'utf-32le' => "\xFF\xFE",
      }

      class << self
        # @return [Symbol] the default parser type (defaults to :ruby)
        attr_reader :parser_type

        def parser_type=(value)
          @parser_type = validated_parser_type(value)
        end

        # Parses a path or set of paths
        #
        # @param [String, Array<String>] paths a path, glob, or list of paths to
        #   parse
        # @param [Array<String, Regexp>] excluded a list of excluded path matchers
        # @param [Fixnum] level the logger level to use during parsing. See
        #   {YARD::Logger}
        # @return [void]
        def parse(paths = ["{lib,app}/**/*.rb", "ext/**/*.c"], excluded = [], level = log.level)
          log.debug("Parsing #{paths.inspect} with `#{parser_type}` parser")
          excluded = excluded.map do |path|
            case path
            when Regexp; path
            else Regexp.new(path.to_s, Regexp::IGNORECASE)
            end
          end
          files = [paths].flatten.
            map {|p| File.directory?(p) ? "#{p}/**/*.{rb,c}" : p }.
            map {|p| p.include?("*") ? Dir[p] : p }.flatten.
            reject {|p| !File.file?(p) || excluded.any? {|re| p =~ re } }

          log.enter_level(level) do
            parse_in_order(*files.uniq)
          end
        end

        # Parses a string +content+
        #
        # @param [String] content the block of code to parse
        # @param [Symbol] ptype the parser type to use. See {parser_type}.
        # @return the parser object that was used to parse +content+
        def parse_string(content, ptype = parser_type)
          new(ptype).parse(StringIO.new(content))
        end

        # Tokenizes but does not parse the block of code
        #
        # @param [String] content the block of code to tokenize
        # @param [Symbol] ptype the parser type to use. See {parser_type}.
        # @return [Array] a list of tokens
        def tokenize(content, ptype = parser_type)
          new(ptype).tokenize(content)
        end

        # Registers a new parser type.
        #
        # @example Registering a parser for "java" files
        #   SourceParser.register_parser_type :java, JavaParser, 'java'
        # @param [Symbol] type a symbolic name for the parser type
        # @param [Base] parser_klass a class that implements parsing and tokenization
        # @param [Array<String>, String, Regexp] extensions a list of extensions or a
        #   regex to match against the file extension
        # @return [void]
        # @see Parser::Base
        def register_parser_type(type, parser_klass, extensions = nil)
          unless Base > parser_klass
            raise ArgumentError, "expecting parser_klass to be a subclass of YARD::Parser::Base"
          end
          parser_type_extensions[type.to_sym] = extensions if extensions
          parser_types[type.to_sym] = parser_klass
        end

        # @return [Hash{Symbol=>Object}] a list of registered parser types
        # @private
        # @since 0.5.6
        attr_reader :parser_types
        undef parser_types
        def parser_types; @@parser_types ||= {} end
        def parser_types=(value) @@parser_types = value end

        # @return [Hash] a list of registered parser type extensions
        # @private
        # @since 0.5.6
        attr_reader :parser_type_extensions
        undef parser_type_extensions
        def parser_type_extensions; @@parser_type_extensions ||= {} end
        def parser_type_extensions=(value) @@parser_type_extensions = value end

        # Finds a parser type that is registered for the extension. If no
        # type is found, the default Ruby type is returned.
        #
        # @return [Symbol] the parser type to be used for the extension
        # @since 0.5.6
        def parser_type_for_extension(extension)
          type = parser_type_extensions.find do |t, exts|
            [exts].flatten.any? {|ext| ext === extension }
          end
          validated_parser_type(type ? type.first : :ruby)
        end

        # Returns the validated parser type. Basically, enforces that :ruby
        # type is never set if the Ripper library is not available
        #
        # @param [Symbol] type the parser type to set
        # @return [Symbol] the validated parser type
        # @private
        def validated_parser_type(type)
          !defined?(::Ripper) && type == :ruby ? :ruby18 : type
        end
        
        # @group Parser Callbacks
        
        # Registers a callback to be called before a list of files is parsed 
        # via {parse}. The block passed to this method will be called on 
        # subsequent parse calls.
        # 
        # @example Installing a simple callback
        #   SourceParser.before_parse_list do |files, globals|
        #     puts "Starting to parse..."
        #   end
        #   YARD.parse('lib/**/*.rb')
        #   # prints "Starting to parse..."
        # 
        # @example Setting global state
        #   SourceParser.before_parse_list do |files, globals|
        #     globals.method_count = 0
        #   end
        #   SourceParser.after_parse_list do |files, globals|
        #     puts "Found #{globals.method_count} methods"
        #   end
        #   class MyCountHandler < Handlers::Ruby::Base
        #     handles :def, :defs
        #     process { globals.method_count += 1 }
        #   end
        #   YARD.parse
        #   # Prints: "Found 37 methods"
        # 
        # @example Using a global callback to cancel parsing
        #   SourceParser.before_parse_list do |files, globals|
        #     return false if files.include?('foo.rb')
        #   end
        # 
        #   YARD.parse(['foo.rb', 'bar.rb']) # callback cancels this method
        #   YARD.parse('bar.rb') # parses normally
        # 
        # @yield [files, globals] the yielded block is called once before 
        #   parsing all files
        # @yieldparam [Array<String>] files the list of files that will be parsed.
        # @yieldparam [OpenStruct] globals a global structure to store arbitrary
        #   state for post processing (see {Handlers::Processor#globals})
        # @yieldreturn [Boolean] if the block returns +false+, parsing is
        #   cancelled.
        # @return [Proc] the yielded block
        # @see after_parse_list
        # @see before_parse_file
        # @since 0.7.0
        def before_parse_list(&block)
          before_parse_list_callbacks << block
        end
        
        # Registers a callback to be called after a list of files is parsed 
        # via {parse}. The block passed to this method will be called on 
        # subsequent parse calls.
        # 
        # @example Printing results after parsing occurs
        #   SourceParser.after_parse_list do
        #     puts "Finished parsing!"
        #   end
        #   YARD.parse
        #   # Prints "Finished parsing!" after parsing files
        # @yield [files, globals] the yielded block is called once before 
        #   parsing all files
        # @yieldparam [Array<String>] files the list of files that will be parsed.
        # @yieldparam [OpenStruct] globals a global structure to store arbitrary
        #   state for post processing (see {Handlers::Processor#globals})
        # @yieldreturn [void] the return value for the block is ignored.
        # @return [Proc] the yielded block
        # @see before_parse_list
        # @see before_parse_file
        # @since 0.7.0
        def after_parse_list(&block)
          after_parse_list_callbacks << block
        end
        
        # Registers a callback to be called before an individual file is parsed. 
        # The block passed to this method will be called on subsequent parse 
        # calls.
        # 
        # To register a callback that is called before the entire list of files
        # is processed, see {before_parse_list}.
        # 
        # @example Installing a simple callback
        #   SourceParser.before_parse_file do |parser|
        #     puts "I'm parsing #{parser.file}"
        #   end
        #   YARD.parse('lib/**/*.rb')
        #   # prints:
        #   "I'm parsing lib/foo.rb"
        #   "I'm parsing lib/foo_bar.rb"
        #   "I'm parsing lib/last_file.rb"
        # 
        # @example Cancel parsing of any test_*.rb files
        #   SourceParser.before_parse_file do |parser|
        #     return false if parser.file =~ /^test_.+\.rb$/
        #   end
        # 
        # @yield [parser] the yielded block is called once before each
        #   file that is parsed. This might happen many times for a single
        #   codebase.
        # @yieldparam [SourceParser] parser the parser object that will {#parse}
        #   the file.
        # @yieldreturn [Boolean] if the block returns +false+, parsing for 
        #   the file is cancelled.
        # @return [Proc] the yielded block
        # @see after_parse_file
        # @see before_parse_list
        # @since 0.7.0
        def before_parse_file(&block)
          before_parse_file_callbacks << block
        end
        
        # Registers a callback to be called after an individual file is parsed. 
        # The block passed to this method will be called on subsequent parse 
        # calls.
        # 
        # To register a callback that is called after the entire list of files
        # is processed, see {after_parse_list}.
        # 
        # @example Printing the length of each file after it is parsed
        #   SourceParser.after_parse_file do |parser|
        #     puts "#{parser.file} is #{parser.contents.size} characters"
        #   end
        #   YARD.parse('lib/**/*.rb')
        #   # prints:
        #   "lib/foo.rb is 1240 characters"
        #   "lib/foo_bar.rb is 248 characters"
        # 
        # @yield [parser] the yielded block is called once after each file 
        #   that is parsed. This might happen many times for a single codebase.
        # @yieldparam [SourceParser] parser the parser object that parsed
        #   the file.
        # @yieldreturn [void] the return value for the block is ignored.
        # @return [Proc] the yielded block
        # @see before_parse_file
        # @see after_parse_list
        # @since 0.7.0
        def after_parse_file(&block)
          after_parse_file_callbacks << block
        end
        
        # @return [Array<Proc>] the list of callbacks to be called before
        #   parsing a list of files. Should only be used for testing.
        # @since 0.7.0
        def before_parse_list_callbacks
          @before_parse_list_callbacks ||= []
        end
        
        # @return [Array<Proc>] the list of callbacks to be called after
        #   parsing a list of files. Should only be used for testing.
        # @since 0.7.0
        def after_parse_list_callbacks
          @after_parse_list_callbacks ||= []
        end
        
        # @return [Array<Proc>] the list of callbacks to be called before
        #   parsing a file. Should only be used for testing.
        # @since 0.7.0
        def before_parse_file_callbacks
          @before_parse_file_callbacks ||= []
        end
        
        # @return [Array<Proc>] the list of callbacks to be called after
        #   parsing a file. Should only be used for testing.
        # @since 0.7.0
        def after_parse_file_callbacks
          @after_parse_file_callbacks ||= []
        end
        
        # @endgroup

        private

        # Parses a list of files in a queue. If a {LoadOrderError} is caught,
        # the file is moved to the back of the queue with a Continuation object
        # that can continue processing the file.
        #
        # @param [Array<String>] files a list of files to queue for parsing
        # @return [void]
        def parse_in_order(*files)
          global_state = OpenStruct.new
          files = files.sort_by {|x| x.length if x }
          files_copy = files.dup
          
          before_parse_list_callbacks.each do |cb|
            return if cb.call(files_copy, global_state) == false
          end
          
          while file = files.shift
            begin
              if file.is_a?(Array) && file.last.is_a?(Continuation)
                log.debug("Re-processing #{file.first}")
                file.last.call
              elsif file.is_a?(String)
                log.debug("Processing #{file}...")
                new(parser_type, true, global_state).parse(file)
              end
            rescue LoadOrderError => e
              # Out of order file. Push the context to the end and we'll call it
              files.push([file, e.message])
            end
          end
          
          after_parse_list_callbacks.each do |cb|
            cb.call(files_copy, global_state)
          end
        end
      end

      register_parser_type :ruby,   Ruby::RubyParser
      register_parser_type :ruby18, Ruby::Legacy::RubyParser
      register_parser_type :c,      CParser, ['c', 'cc', 'cxx', 'cpp']

      self.parser_type = :ruby

      # @return [String] the filename being parsed by the parser.
      attr_reader :file

      # @return [Symbol] the parser type associated with the parser instance.
      #   This should be set by the {#initialize constructor}.
      attr_reader :parser_type
      
      # @return [OpenStruct] an open struct containing arbitrary global state
      #   shared between files and handlers.
      # @since 0.7.0
      attr_reader :globals
      
      # @return [String] the contents of the file to be parsed
      # @since 0.7.0
      attr_reader :contents

      # Creates a new parser object for code parsing with a specific parser type.
      #
      # @param [Symbol] parser_type the parser type to use
      # @param [Boolean] load_order_errors whether or not to raise the {LoadOrderError}
      # @param [OpenStruct] globals global state to be re-used across separate source files
      def initialize(parser_type = SourceParser.parser_type, load_order_errors = false, globals = nil)
        @load_order_errors = load_order_errors
        @file = '(stdin)'
        @globals = globals || OpenStruct.new
        self.parser_type = parser_type
      end

      # The main parser method. This should not be called directly. Instead,
      # use the class methods {parse} and {parse_string}.
      #
      # @param [String, #read, Object] content the source file to parse
      # @return [Object, nil] the parser object used to parse the source
      def parse(content = __FILE__)
        case content
        when String
          @file = File.cleanpath(content)
          content = convert_encoding(File.read_binary(file))
          checksum = Registry.checksum_for(content)
          return if Registry.checksums[file] == checksum

          if Registry.checksums.has_key?(file)
            log.info "File '#{file}' was modified, re-processing..."
          end
          Registry.checksums[@file] = checksum
          self.parser_type = parser_type_for_filename(file)
        else
          content = content.read if content.respond_to? :read
        end

        @contents = content
        @parser = parser_class.new(content, file)
        
        self.class.before_parse_file_callbacks.each do |cb|
          return @parser if cb.call(self) == false
        end
          
        @parser.parse
        post_process
        
        self.class.after_parse_file_callbacks.each do |cb|
          cb.call(self)
        end
        
        @parser
      rescue ArgumentError, NotImplementedError => e
        log.warn("Cannot parse `#{file}': #{e.message}")
      rescue ParserSyntaxError => e
        log.warn(e.message.capitalize)
      end

      # Tokenizes but does not parse the block of code using the current {#parser_type}
      #
      # @param [String] content the block of code to tokenize
      # @return [Array] a list of tokens
      def tokenize(content)
        @parser = parser_class.new(content, file)
        @parser.tokenize
      end

      private

      # Searches for encoding line and forces encoding
      # @since 0.5.3
      def convert_encoding(content)
        return content unless content.respond_to?(:force_encoding)
        if content =~ ENCODING_LINE
          content.force_encoding($1)
        else
          old_encoding = content.encoding
          content.force_encoding('binary')
          ENCODING_BYTE_ORDER_MARKS.each do |encoding, bom|
            bom.force_encoding('binary')
            if content[0,bom.size] == bom
              content.force_encoding(encoding)
              return content
            end
          end
          content.force_encoding(old_encoding)
          content
        end
      end

      # Runs a {Handlers::Processor} object to post process the parsed statements.
      # @return [void]
      def post_process
        return unless @parser.respond_to? :enumerator
        return unless enumerator = @parser.enumerator
        post = Handlers::Processor.new(@file, @load_order_errors, @parser_type, @globals)
        post.process(enumerator)
      end

      def parser_type=(value)
        @parser_type = self.class.validated_parser_type(value)
      end

      # Guesses the parser type to use depending on the file extension.
      #
      # @param [String] filename the filename to use to guess the parser type
      # @return [Symbol] a parser type that matches the filename
      def parser_type_for_filename(filename)
        ext = (File.extname(filename)[1..-1] || "").downcase
        type = self.class.parser_type_for_extension(ext)
        parser_type == :ruby18 && type == :ruby ? :ruby18 : type
      end

      # @since 0.5.6
      def parser_class
        klass = self.class.parser_types[parser_type]
        raise ArgumentError, "invalid parser type '#{parser_type}' or unrecognized file", caller[1..-1] if !klass
        klass
      end
    end
  end
end

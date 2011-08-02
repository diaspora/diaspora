require 'cucumber/parser/gherkin_builder'
require 'gherkin/formatter/filter_formatter'
require 'gherkin/formatter/tag_count_formatter'
require 'gherkin/parser/parser'

module Cucumber
  class FeatureFile
    FILE_COLON_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/ #:nodoc:
    DEFAULT_ENCODING = "UTF-8" #:nodoc:
    COMMENT_OR_EMPTY_LINE_PATTERN = /^\s*#|^\s*$/ #:nodoc:
    ENCODING_PATTERN = /^\s*#\s*encoding\s*:\s*([^\s]+)/ #:nodoc:

    # The +uri+ argument is the location of the source. It can be a path
    # or a path:line1:line2 etc. If +source+ is passed, +uri+ is ignored.
    def initialize(uri, source=nil)
      @source = source
      _, @path, @lines = *FILE_COLON_LINE_PATTERN.match(uri)
      if @path
        @lines = @lines.split(':').map { |line| line.to_i }
      else
        @path = uri
      end
    end

    # Parses a file and returns a Cucumber::Ast
    # If +configuration_filters+ contains any filters, the result will
    # be filtered.
    def parse(configuration_filters, tag_counts)
      filters = @lines || configuration_filters

      builder             = Cucumber::Parser::GherkinBuilder.new
      filter_formatter    = filters.empty? ? builder : Gherkin::Formatter::FilterFormatter.new(builder, filters)
      tag_count_formatter = Gherkin::Formatter::TagCountFormatter.new(filter_formatter, tag_counts)
      parser              = Gherkin::Parser::Parser.new(tag_count_formatter, true, "root", false)

      begin
        parser.parse(source, @path, 0)
        ast = builder.ast
        return nil if ast.nil? # Filter caused nothing to match
        ast.language = parser.i18n_language
        ast.file = @path
        ast
      rescue Gherkin::Lexer::LexingError, Gherkin::Parser::ParseError => e
        e.message.insert(0, "#{@path}: ")
        raise e
      end
    end

    def source
      @source ||= if @path =~ /^http/
        require 'open-uri'
        open(@path).read
      else
        begin
          source = File.open(@path, Cucumber.file_mode('r', DEFAULT_ENCODING)).read
          encoding = encoding_for(source)
          if(DEFAULT_ENCODING.downcase != encoding.downcase)
            # Read the file again - it's explicitly declaring a different encoding
            source = File.open(@path, Cucumber.file_mode('r', encoding)).read
            source = to_default_encoding(source, encoding)
          end
          source
        rescue Errno::EACCES => e
          e.message << "\nCouldn't open #{File.expand_path(@path)}"
          raise e
        rescue Errno::ENOENT => e
          # special-case opening features, because this could be a new user:
          if(@path == 'features')
            STDERR.puts("You don't have a 'features' directory.  Please create one to get started.",
                        "See http://cukes.info/ for more information.")
            exit 1
          end
          raise e
        end
      end
    end

    private
    
    def encoding_for(source)
      encoding = DEFAULT_ENCODING
      source.each_line do |line|
        break unless COMMENT_OR_EMPTY_LINE_PATTERN =~ line
        if ENCODING_PATTERN =~ line
          encoding = $1
          break
        end
      end
      encoding
    end

    def to_default_encoding(string, encoding)
      if string.respond_to?(:encode)
        string.encode(DEFAULT_ENCODING)
      else
        require 'iconv'
        Iconv.new(DEFAULT_ENCODING, encoding).iconv(string)
      end
    end
  end
end

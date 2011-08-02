require 'yaml'
require 'gherkin/rubify'
require 'gherkin/native'

module Gherkin
  class I18n
    native_impl('gherkin') unless defined?(BYPASS_NATIVE_IMPL)

    FEATURE_ELEMENT_KEYS = %w{feature background scenario scenario_outline examples}
    STEP_KEYWORD_KEYS    = %w{given when then and but}
    KEYWORD_KEYS         = FEATURE_ELEMENT_KEYS + STEP_KEYWORD_KEYS
    LANGUAGES            = YAML.load_file(File.dirname(__FILE__) + '/i18n.yml')

    class << self
      include Rubify

      # Used by code generators for other lexer tools like pygments lexer and textmate bundle
      def all
        LANGUAGES.keys.sort.map{|iso_code| get(iso_code)}
      end

      def get(iso_code)
        languages[iso_code] ||= new(iso_code)
      end

      # Returns all keyword translations and aliases of +keywords+, escaped and joined with <tt>|</tt>.
      # This method is convenient for editor support and syntax highlighting engines for Gherkin, where
      # there is typically a code generation tool to generate regular expressions for recognising the
      # various I18n translations of Gherkin's keywords.
      #
      # The +keywords+ arguments can be one of <tt>:feature</tt>, <tt>:background</tt>, <tt>:scenario</tt>, 
      # <tt>:scenario_outline</tt>, <tt>:examples</tt>, <tt>:step</tt>.
      def keyword_regexp(*keywords)
        unique_keywords = all.map do |i18n|
          keywords.map do |keyword|
            if keyword.to_s == 'step'
              i18n.step_keywords.to_a
            else
              i18n.keywords(keyword).to_a
            end
          end
        end
        
        unique_keywords.flatten.compact.map{|kw| kw.to_s}.sort.reverse.uniq.join('|').gsub(/\*/, '\*')
      end

      def code_keywords
        rubify(all.map{|i18n| i18n.code_keywords}).flatten.uniq.sort
      end

      def code_keyword_for(gherkin_keyword)
        gherkin_keyword.gsub(/[\s',!]/, '').strip
      end

      def language_table
        require 'stringio'
        require 'gherkin/formatter/pretty_formatter'
        require 'gherkin/formatter/model'
        io = StringIO.new
        pf = Gherkin::Formatter::PrettyFormatter.new(io, false, false)
        table = all.map do |i18n|
          Formatter::Model::Row.new([], [i18n.iso_code, i18n.keywords('name')[0], i18n.keywords('native')[0]], nil)
        end
        pf.table(table)
        io.string
      end

      def unicode_escape(word, prefix="\\u")
        word = word.unpack("U*").map do |c|
          if c > 127 || c == 32
            "#{prefix}%04x" % c
          else
            c.chr
          end
        end.join
      end

      private

      def languages
        @languages ||= {}
      end
    end

    attr_reader :iso_code

    def initialize(iso_code)
      @iso_code = iso_code
      @keywords = LANGUAGES[iso_code]
      raise "Language not supported: #{iso_code.inspect}" if @iso_code.nil?
      @keywords['grammar_name'] = @keywords['name'].gsub(/\s/, '')
    end

    def lexer(listener, force_ruby=false)
      begin
        if force_ruby
          rb(listener)
        else
          begin
            c(listener)
          rescue NameError, LoadError => e
            warn("WARNING: #{e.message}. Reverting to Ruby lexer.")
            rb(listener)
          end
        end
      rescue LoadError => e
        raise I18nLexerNotFound, "No lexer was found for #{i18n_language_name} (#{e.message}). Supported languages are listed in gherkin/i18n.yml."
      end
    end

    def c(listener)
      require 'gherkin/c_lexer'
      CLexer[underscored_iso_code].new(listener)
    end

    def rb(listener)
      require 'gherkin/rb_lexer'
      RbLexer[underscored_iso_code].new(listener)
    end

    def js(listener)
      require 'gherkin/js_lexer'
      JsLexer[underscored_iso_code].new(listener)
    end

    def underscored_iso_code
      @iso_code.gsub(/[\s-]/, '_').downcase
    end

    # Keywords that can be used in Gherkin source
    def step_keywords
      STEP_KEYWORD_KEYS.map{|iso_code| keywords(iso_code)}.flatten.uniq
    end

    # Keywords that can be used in code
    def code_keywords
      result = step_keywords.map{|keyword| self.class.code_keyword_for(keyword)}
      result.delete('*')
      result
    end

    def keywords(key)
      key = key.to_s
      raise "No #{key.inspect} in #{@keywords.inspect}" if @keywords[key].nil?
      @keywords[key].split('|').map{|keyword| real_keyword(key, keyword)}
    end

    def keyword_table
      require 'stringio'
      require 'gherkin/formatter/pretty_formatter'
      require 'gherkin/formatter/model'
      io = StringIO.new
      pf = Gherkin::Formatter::PrettyFormatter.new(io, false, false)

      gherkin_keyword_table = KEYWORD_KEYS.map do |key|
        Formatter::Model::Row.new([], [key, keywords(key).map{|keyword| %{"#{keyword}"}}.join(', ')], nil)
      end
      
      code_keyword_table = STEP_KEYWORD_KEYS.map do |key|
        code_keywords = keywords(key).reject{|keyword| keyword == '* '}.map do |keyword|
          %{"#{self.class.code_keyword_for(keyword)}"}
        end.join(', ')
        Formatter::Model::Row.new([], ["#{key} (code)", code_keywords], nil)
      end
      
      pf.table(gherkin_keyword_table + code_keyword_table)
      io.string
    end

    private

    def real_keyword(key, keyword)
      if(STEP_KEYWORD_KEYS.index(key))
        (keyword + ' ').sub(/< $/, '')
      else
        keyword
      end
    end
  end
end

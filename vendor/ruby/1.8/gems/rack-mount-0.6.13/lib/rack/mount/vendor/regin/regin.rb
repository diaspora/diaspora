module Regin
  autoload :Alternation, 'regin/alternation'
  autoload :Anchor, 'regin/anchor'
  autoload :Atom, 'regin/atom'
  autoload :Character, 'regin/character'
  autoload :CharacterClass, 'regin/character_class'
  autoload :Collection, 'regin/collection'
  autoload :Expression, 'regin/expression'
  autoload :Group, 'regin/group'
  autoload :Options, 'regin/options'
  autoload :Parser, 'regin/parser'

  # Detect named capture support
  begin
    old_debug, $DEBUG = $DEBUG, nil
    eval('foo = /(?<foo>.*)/').named_captures

    # Returns true if the interpreter is using the Oniguruma Regexp lib
    # and supports named captures.
    #
    #   /(?<foo>bar)/
    def self.regexp_supports_named_captures?
      true
    end
  rescue SyntaxError, NoMethodError
    def self.regexp_supports_named_captures? #:nodoc:
      false
    end
  ensure
    $DEBUG = old_debug
  end


  POSIX_BRACKET_TYPES = %w(
    alnum alpha ascii blank cntrl digit graph
    lower print punct space upper word xdigit
    foo
  )

  # Returns array of supported POSX bracket types
  def self.supported_posix_bracket_types
    @supported_posix_bracket_types ||= []
  end

  # Detect supported posix bracket types
  begin
    old_debug, $DEBUG = $DEBUG, nil

    POSIX_BRACKET_TYPES.each do |type|
      begin
        eval("foo = /[[:#{type}:]]/")
        supported_posix_bracket_types << type
      rescue SyntaxError, RegexpError
      end
    end
  ensure
    $DEBUG = old_debug
  end


  # Parses Regexp and returns a Expression data structure.
  def self.parse(regexp)
    Parser.parse_regexp(regexp)
  end

  # Recompiles Regexp by parsing it and turning it back into a Regexp.
  #
  # (In the future Regin will perform some Regexp optimizations
  # such as removing unnecessary captures and options)
  def self.compile(source)
    regexp = Regexp.compile(source)
    expression = parse(regexp)
    Regexp.compile(expression.to_s(true), expression.flags)
  end
end

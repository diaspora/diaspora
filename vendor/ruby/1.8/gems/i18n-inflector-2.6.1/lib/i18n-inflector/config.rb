# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains configuration of I18n::Inflector module.

module I18n

  module Inflector

    # This module contains submodules and module
    # methods for handling global configuration
    # of the engine.
    module Config

      # @private
      def get_i18n_reserved_keys
        return I18n::RESERVED_KEYS                  if defined?(I18n::RESERVED_KEYS)
        return I18n::Backend::Base::RESERVED_KEYS   if defined?(I18n::Backend::Base::RESERVED_KEYS)
        return I18n::Backend::Simple::RESERVED_KEYS if defined?(I18n::Backend::Simple::RESERVED_KEYS)
        return RESERVED_KEYS                        if defined?(RESERVED_KEYS)
        []
      end
      module_function :get_i18n_reserved_keys

      # @private
      def all_consts(obj, f=String)
        obj.constants.map do |c|
          v = obj.const_get(c)
          (v.is_a?(f) && c != 'ALL') ? v : nil
        end.compact.uniq
      end
      module_function :all_consts

      # @private
      def gen_regexp(ary)
        ::Regexp.new '[' << ary.join << ']'
      end
      module_function :gen_regexp

      # Prefix that makes option a controlling option.
      OPTION_PREFIX = InflectionOptions::OPTION_PREFIX

      # Regexp matching a prefix that makes option
      # a controlling option.
      OPTION_PREFIX_REGEXP = Regexp.new('^' << OPTION_PREFIX)

      # This module contains keys that have special
      # meaning.
      module Keys

        # A Symbol that is used to mark default token
        # in configuration and in options.
        DEFAULT_TOKEN = :default

        # All keys
        ALL = HSet.new Config.all_consts(self, Symbol)
      end

      # This module contains characters that are markers
      # giving the shape for a pattern and its elements.
      module Markers

        # A character that is used to mark pattern.
        PATTERN       = '@'

        # A character that is used to mark a strict kind.
        STRICT_KIND   = '@'

        # A character that is used to open a pattern.
        PATTERN_BEGIN = '{'

        # A character that ends a pattern.
        PATTERN_END   = '}'

        # A character that indicates an alias.
        ALIAS         = '@'

        # A character used to mark token value as loud.
        LOUD_VALUE    = '~'

        # All markers.
        ALL = Config.all_consts(self)

      end # module Markers

      module Escapes

        # A general esape symbol.
        ESCAPE    = '\\'

        # A regular expression that catches escape symbols.
        ESCAPE_R  = /\\([^\\])/

        # A list of escape symbols that cause a pattern to be escaped.
        PATTERN   = HSet[Markers::PATTERN, Escapes::ESCAPE]

      end # module Escapes

      # This module contains constants that define
      # operators in patterns.
      module Operators

        # This module contains constants that define
        # operators in patterns that handle token
        # groups or tokens.
        module Tokens

          # A character used to mark patterns as complex
          # and to separate token groups assigned to different
          # strict kinds.
          AND       = '+'

          # A character that is used to separate tokens
          # or token groups within a pattern. 
          OR        = '|'

          # A character used to assign value to a token
          # or a group of tokens.
          ASSIGN    = ':'

          # A character used to create a virtual token
          # that always matches.
          WILDCARD  = '*'

          # All token groups operators.
          ALL       = Config.all_consts(self)

        end # module Tokens

        # This module contains constants that are operators
        # in patterns that handle token groups or tokens.
        module Token

          # A character used to separate multiple tokens.
          OR        = ','

          # A character used to mark tokens as negative.
          NOT       = '!'

          # All token operators.
          ALL       = Config.all_consts(self)

        end # module Token

        # All operators.
        ALL = Tokens::ALL | Token::ALL

      end # module Operators

      # This module contains constants defining
      # reserved characters in tokens and kinds.
      module Reserved

        # Reserved keys.
        KEYS = HSet.new  Config.get_i18n_reserved_keys  +
                         Config::Keys::ALL.to_a         +
                         InflectionOptions.known.values

        # This module contains constants defining
        # reserved characters in token identifiers.
        module Tokens

          # Reserved characters in token identifiers placed in configuration.
          DB        = (Operators::ALL | Markers::ALL) - [Markers::LOUD_VALUE]

          # Reserved characters in token identifiers passed as options.
          OPTION    = DB

          # Reserved characters in token identifiers placed in patterns.
          PATTERN   = OPTION - [Operators::Tokens::WILDCARD]

          # This module contains constants defining
          # regular expressions for reserved characters
          # in token identifiers.
          module Regexp

            # Reserved characters in token identifiers placed in configuration.
            DB      = Config.gen_regexp Tokens::DB

            # Reserved characters in token identifiers passed as options.
            OPTION  = Config.gen_regexp Tokens::OPTION

            # Reserved characters in token identifiers placed in patterns.
            PATTERN = Config.gen_regexp Tokens::PATTERN

          end # module Regexp

          # This method checks if the given +token+ is invalid,
          # that means it's either +nil+ or empty or it matches
          # the refular expression given as +root+.
          # 
          # @api public
          # @param [Symbol,String] token the identifier of a token
          # @param [Regexp] root the regular expression used to test
          # @return [Boolean] +true+ if the given +token+ is
          #   invalid, +false+ otherwise
          def invalid?(token, root)
            token = token.to_s
            token.empty?                                          ||
            (root == Regexp::PATTERN && Keys::ALL[token.to_sym])  ||
            Regexp.const_get(root) =~ token
          end
          module_function :invalid?

        end # module Tokens

        # This module contains constants defining
        # reserved characters in kind identifiers.
        module Kinds

          # Reserved characters in kind identifiers placed in configuration.
          DB        = (Operators::ALL | Markers::ALL) - [Markers::ALIAS, Markers::LOUD_VALUE]

          # Reserved characters in kind identifiers passed as option values.
          OPTION    = DB

          # Reserved characters in kind identifiers placed in patterns.
          PATTERN   = (Operators::ALL | Markers::ALL) - [Markers::LOUD_VALUE]

          # This module contains constants defining
          # regular expressions for reserved characters
          # in kind identifiers.
          module Regexp

            # Reserved characters in kind identifiers placed in configuration.
            DB      = Config.gen_regexp Kinds::DB

            # Reserved characters in kind identifiers passed as option values.
            OPTION  = Config.gen_regexp Kinds::OPTION

            # Reserved characters in kind identifiers placed in patterns.
            PATTERN = Config.gen_regexp Kinds::PATTERN

          end # module Regexp

          # This method checks if the given +kind+ is invalid,
          # that means it's either +nil+ or empty or it matches
          # the refular expression given as +root+.
          # 
          # @api public
          # @param [Symbol,String] kind the identifier of a kind
          # @param [Regexp] root the regular expression used to test
          # @return [Boolean] +true+ if the given +kind+ is
          #   invalid, +false+ otherwise
          def invalid?(kind, root)
            kind = kind.to_s
            kind.empty?                                           ||
             (root != Regexp::OPTION &&
             (KEYS[kind.to_sym] || OPTION_PREFIX_REGEXP =~ kind)) ||
            Regexp.const_get(root) =~ kind
          end
          module_function :invalid?

        end # module Kinds

      end # module Reserved

      # A string for regular expression that catches patterns.
      PATTERN_RESTR   = '(.?)'  << Markers::PATTERN       <<
                        '([^\\' << Markers::PATTERN_BEGIN << ']*)\\' << Markers::PATTERN_BEGIN <<
                        '([^\\' << Markers::PATTERN_END   << ']+)\\' << Markers::PATTERN_END   <<
                        '((?:\\'<< Markers::PATTERN_BEGIN << '([^\\' << Markers::PATTERN_BEGIN <<
                        ']+)\\' << Markers::PATTERN_END   << ')*)'

      # A string for regular expression that extracts additional patterns attached.
      MULTI_RESTR     = '\\'    << Markers::PATTERN_BEGIN          <<
                        '([^\\' << Markers::PATTERN_END + ']+)\\'  <<
                        Markers::PATTERN_END

      # A regular expression that catches token groups or single tokens.
      TOKENS_RESTR   = '(?:'   <<
                       '([^'   << Operators::Tokens::ASSIGN  << '\\'      << Operators::Tokens::OR << ']+)' <<
                                  Operators::Tokens::ASSIGN  << '+'       <<
                       '([^\\' << Operators::Tokens::OR      << ']+)\1?)' <<
                       '|([^'  << Operators::Tokens::ASSIGN  << '\\'      << Operators::Tokens::OR << ']+)'

      # A regular expression that catches patterns.
      PATTERN_REGEXP  = Regexp.new PATTERN_RESTR

      # A regular expression that extracts additional patterns attached.
      MULTI_REGEXP    = Regexp.new MULTI_RESTR

      # A regular expression that catches token groups or single tokens.
      TOKENS_REGEXP   = Regexp.new TOKENS_RESTR

    end # module Config

    # @private
    PATTERN_MARKER  = Config::Markers::PATTERN
    # @private
    NAMED_MARKER    = Config::Markers::STRICT_KIND
    # @private
    ALIAS_MARKER    = Config::Markers::ALIAS
    # @private
    ESCAPE          = Config::Escapes::ESCAPE
    # @private
    ESCAPE_R        = Config::Escapes::ESCAPE_R
    # @private
    ESCAPES         = Config::Escapes::PATTERN
    # @private
    PATTERN         = Config::PATTERN_REGEXP
    # @private
    TOKENS          = Config::TOKENS_REGEXP
    # @private
    INFLECTOR_RESERVED_KEYS = Config::Reserved::KEYS

  end # module Inflector

end # module I18n

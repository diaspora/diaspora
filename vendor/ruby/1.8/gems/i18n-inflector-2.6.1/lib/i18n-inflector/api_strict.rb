# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains I18n::Inflector::API_Strict class,
# which handles public API for managing inflection data
# for named patterns (strict kinds).

module I18n

  module Inflector

    # This class contains common operations
    # that can be performed on inflection data describing
    # strict kinds and tokens assigned to them (used in named
    # patterns). It is used by the regular {I18n::Inflector::API API}
    # and present there as {I18n::Inflector::API#strict strict}
    # instance attribute.
    # 
    # It operates on the database containing instances
    # of {I18n::Inflector::InflectionData_Strict} indexed by locale
    # names and has methods to access the inflection data in an easy way.
    # It can operate on a database and options passed to initializer;
    # if they aren't passet it will create them.
    # 
    # ==== Usage
    # You can access the instance of this class attached to
    # default I18n backend by calling:
    #   I18n.backend.inflector.strict
    # or in a short form:
    #   I18n.inflector.strict
    # 
    # In most cases using the regular {I18n::Inflector::API} instance
    # may be sufficient to operate on inflection data,
    # because the regular API (instantiated as <tt>I18n.inflector</tt>)
    # is aware of strict kinds and can pass calls from +API_Strict+
    # object if the +kind+ argument given in a method call
    # contains the +@+ symbol.
    # 
    # For an instance connected to default I18n backend
    # the object containing inflection options is shared
    # with the regular API.
    # 
    # @api public
    class API_Strict

      # Initilizes inflector by connecting to internal databases
      # used for storing inflection data and options.
      # 
      # @api public
      # @note If any given option is +nil+ then a proper object will be created.
      #   If it's given, then it will be referenced, not copied.
      # @param [Hash,nil] idb the strict inflections databases indexed by locale
      # @param [I18n::Inflector::InflectionOptions,nil] options the inflection options
      def initialize(idb=nil, options=nil)
        @idb      = idb.nil?      ? {} : idb
        @options  = options.nil?  ? I18n::Inflector::InflectionOptions.new : options
        @lazy_locales = LazyHashEnumerator.new(@idb)
        @inflected_locales_cache = Hash.new
      end

      # Creates an empty strict inflections database for the specified locale.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @param [Symbol] locale the locale for which the inflections database
      #   should be created
      # @return [I18n::Inflector::InflectionData_Strict] the new object for keeping
      #   inflection data
      def new_database(locale)
        locale = prep_locale(locale)
        @inflected_locales_cache.clear
        @idb[locale] = I18n::Inflector::InflectionData_Strict.new(locale)
      end

      # Attaches {I18n::Inflector::InflectionData_Strict} instance to the
      # current object.
      #
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @note It doesn't create copy of inflection database, it registers the given object.
      # @param [I18n::Inflector::InflectionData_Strict] idb inflection data to add
      # @return [I18n::Inflector::InflectionData_Strict] the given +idb+ or +nil+ if something
      #   went wrong (e.g. +nil+ was given as an argument)
      def add_database(db)
        return nil if db.nil?
        locale = prep_locale(db.locale)
        delete_database(locale)
        @inflected_locales_cache.clear
        @idb[locale] = db
      end

      # Deletes a strict inflections database for the specified locale.
      # 
      # @api public
      # @note It detaches the database from {I18n::Inflector::API_Strict} instance.
      #   Other objects referring to it directly may still use it.
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @param [Symbol] locale the locale for which the inflections database is to be deleted.
      # @return [void]
      def delete_database(locale)
        locale = prep_locale(locale)
        return nil if @idb[locale].nil?
        @inflected_locales_cache.clear
        @idb[locale] = nil
      end

      # Checks if the given locale was configured to support strict inflection.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [Boolean] +true+ if a locale supports inflection
      # @overload inflected_locale?
      #   Checks if the current locale was configured to support inflection.
      #   @return [Boolean] +true+ if the current locale supports inflection
      # @overload inflected_locale?(locale)
      #   Checks if the given locale was configured to support inflection.
      #   @param [Symbol] locale the locale to test
      #   @return [Boolean] +true+ if the given locale supports inflection
      def inflected_locale?(locale=nil)
        not @idb[prep_locale(locale)].nil? rescue false
      end
      alias_method :locale?,            :inflected_locale?
      alias_method :locale_supported?,  :inflected_locale?

      # Iterates through locales which have configured strict inflection support.
      # 
      # @api public
      # @return [LazyArrayEnumerator] the lazy enumerator
      # @yield [locale] optional block in which each kind will be yielded
      # @yieldparam [Symbol] locale the inflected locale identifier
      # @yieldreturn [LazyArrayEnumerator] the lazy enumerator
      # @overload each_inflected_locale
      #   Iterates through locales which have configured inflection support.
      #   @return [LazyArrayEnumerator] the lazy enumerator
      # @overload each_inflected_locale(kind)
      #   Iterates through locales which have configured inflection support for the given +kind+.
      #   @param [Symbol] kind the identifier of a kind
      #   @return [LazyArrayEnumerator] the lazy enumerator
      def each_inflected_locale(kind=nil, &block)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        i = @lazy_locales.reject  { |lang,data| data.empty?           }
        i = i.select              { |lang,data| data.has_kind?(kind)  } unless kind.nil?
        i.each_key(&block)
      end
      alias_method :each_locale,            :each_inflected_locale
      alias_method :each_supported_locale,  :each_inflected_locale

      # Gets locales which have configured strict inflection support.
      # 
      # @api public
      # @return [Array<Symbol>] the array containing locales that support inflection
      # @overload inflected_locales
      #   Gets locales which have configured inflection support.
      #   @return [Array<Symbol>] the array containing locales that support inflection
      # @overload inflected_locales(kind)
      #   Gets locales which have configured inflection support for the given +kind+.
      #   @param [Symbol] kind the identifier of a kind
      #   @return [Array<Symbol>] the array containing locales that support inflection
      def inflected_locales(kind=nil)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        r = ( @inflected_locales_cache[kind] ||= each_inflected_locale(kind).to_a )
        r.nil? ? r : r.dup
      end
      alias_method :locales,            :inflected_locales
      alias_method :supported_locales,  :inflected_locales

      # Iterates through known strict inflection kinds.
      # 
      # @api public
      # @return [LazyArrayEnumerator] the lazy enumerator
      # @yield [kind] optional block in which each kind will be yielded
      # @yieldparam [Symbol] kind the inflection kind
      # @yieldreturn [LazyArrayEnumerator] the lazy enumerator
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload kinds
      #   Iterates through known inflection kinds for the current locale.
      #   @return [LazyArrayEnumerator] the lazy enumerator
      # @overload kinds(locale)
      #   Iterates through known inflection kinds for the given +locale+.
      #   @param [Symbol] locale the locale for which kinds should be listed
      #   @return [LazyArrayEnumerator] the lazy enumerator
      def each_kind(locale=nil, &block)
        data_safe(locale).each_kind(&block)
      end
      alias_method :each_inflection_kind, :each_kind

      # Gets known strict inflection kinds.
      # 
      # @api public
      # @return [Array<Symbol>] the array containing known inflection kinds
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload kinds
      #   Gets known inflection kinds for the current locale.
      #   @return [Array<Symbol>] the array containing known inflection kinds
      # @overload kinds(locale)
      #   Gets known inflection kinds for the given +locale+.
      #   @param [Symbol] locale the locale for which kinds should be listed
      #   @return [Array<Symbol>] the array containing known inflection kinds      
      def kinds(locale=nil)
        each_kind(locale).to_a
      end
      alias_method :inflection_kinds, :kinds

      # Tests if a strict kind exists.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [Boolean] +true+ if the given +kind+ exists, +false+ otherwise
      # @overload has_kind?(kind)
      #   Tests if a strict kind exists for the current locale.
      #   @param [Symbol] kind the identifier of a kind
      #   @return [Boolean] +true+ if the given +kind+ exists, +false+ otherwise
      # @overload has_kind?(kind, locale)
      #   Tests if a strict kind exists for the given +locale+.
      #   @param [Symbol,String] kind the identifier of a kind
      #   @param [Symbol] locale the locale identifier
      #   @return [Boolean] +true+ if the given +kind+ exists, +false+ otherwise
      def has_kind?(kind, locale=nil)
        return false if (kind.nil? || kind.to_s.empty?)
        data_safe(locale).has_kind?(kind.to_sym)
      end

      # Reads default token of the given strict +kind+.
      # 
      # @api public
      # @return [Symbol,nil] the default token or +nil+
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload default_token(kind)
      #   This method reads default token of the given +kind+ and the current locale.
      #   @param [Symbol,String] kind the kind of tokens
      #   @return [Symbol,nil] the default token or +nil+ if
      #     there is no default token
      # @overload default_token(kind, locale)
      #   This method reads default token of the given +kind+ and the given +locale+.
      #   @param [Symbol,String] kind the kind of tokens
      #   @param [Symbol] locale the locale to use
      #   @return [Symbol,nil] the default token or +nil+ if
      #     there is no default token
      def default_token(kind, locale=nil)
        return nil if (kind.nil? || kind.to_s.empty?)
        data_safe(locale).get_default_token(kind.to_sym)
      end

      # Checks if the given +token+ belonging to a strict kind is an alias.
      # 
      # @api public
      # @return [Boolean] +true+ if the given +token+ is an alias, +false+ otherwise
      # @raise [I18n::InvalidLocale] if the given +locale+ is invalid
      # @raise [ArgumentError] if the count of arguments is invalid
      # @overload has_alias?(token, kind)
      #   Uses the current locale and the given +kind+ to check if the given +token+ is an alias.
      #   @param [Symbol,String] token name of the checked token
      #   @param [Symbol,String] kind the kind of the given token
      #   @return [Boolean] +true+ if the given +token+ is an alias, +false+ otherwise
      # @overload has_alias?(token, kind, locale)
      #   Uses the given +locale+ and +kind+ to check if the given +token+ is an alias.
      #   @param [Symbol,String] token name of the checked token
      #   @param [Symbol,String] kind the kind of the given token
      #   @param [Symbol] locale the locale to use
      #   @return [Boolean] +true+ if the given +token+ is an alias, +false+ otherwise
      def has_alias?(*args)
        token, kind, locale = tkl_args(args)
        return false if (token.nil? || kind.nil?)
        data_safe(locale).has_alias?(token, kind)
      end
      alias_method :token_is_alias?, :has_alias?

      # Checks if the given +token+ belonging to a strict kind is a true token (not alias).
      # 
      # @api public
      # @return [Boolean] +true+ if the given +token+ is a true token, +false+ otherwise
      # @raise [I18n::InvalidLocale] if the given +locale+ is invalid
      # @raise [ArgumentError] if the count of arguments is invalid
      # @overload has_true_token?(token, kind)
      #   Uses the current locale and the given +kind+ to check if the given +token+ is a true token.
      #   @param [Symbol,String] token name of the checked token
      #   @param [Symbol,String] kind the kind of the given token
      #   @return [Boolean] +true+ if the given +token+ is a true token, +false+ otherwise
      # @overload has_true_token?(token, kind, locale)
      #   Uses the given +locale+ and +kind+ to check if the given +token+ is a true token.
      #   @param [Symbol,String] token name of the checked token
      #   @param [Symbol,String] kind the kind of the given token
      #   @param [Symbol] locale the locale to use
      #   @return [Boolean] +true+ if the given +token+ is a true token, +false+ otherwise
      def has_true_token?(*args)
        token, kind, locale = tkl_args(args)
        return false if (token.nil? || kind.nil?)
        data_safe(locale).has_true_token?(token, kind)
      end
      alias_method :token_is_true?, :has_true_token?

       # Checks if the given +token+ belonging to a strict kind exists. It may be an alias or a true token.
       # 
       # @api public
       # @return [Boolean] +true+ if the given +token+ exists, +false+ otherwise
       # @raise [I18n::InvalidLocale] if the given +locale+ is invalid
       # @raise [ArgumentError] if the count of arguments is invalid
       # @overload has_token?(token, kind)
       #   Uses the current locale and the given kind +kind+ to check if the given +token+ exists.
       #   @param [Symbol,String] token name of the checked token
       #   @param [Symbol,String] kind the kind of the given token
       #   @return [Boolean] +true+ if the given +token+ exists, +false+ otherwise
       # @overload has_token?(token, kind, locale)
       #   Uses the given +locale+ and +kind+ to check if the given +token+ exists.
       #   @param [Symbol,String] token name of the checked token
       #   @param [Symbol,String] kind the kind of the given token
       #   @param [Symbol] locale the locale to use
       #   @return [Boolean] +true+ if the given +token+ exists, +false+ otherwise
       def has_token?(*args)
         token, kind, locale = tkl_args(args)
         return false if (token.nil? || kind.nil?)
         data_safe(locale).has_token?(token, kind)
       end
       alias_method :token_exists?, :has_token?

      # Gets true token for the given +token+ belonging to
      # a strict kind. If the token is an alias it will be resolved
      # and a true token (target) will be returned.
      # 
      # @api public
      # @return [Symbol,nil] the true token or +nil+
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload true_token(token, kind)
      #   Uses the current +locale+ and the given +kind+ to get a real token
      #   for the given +token+. If the token is an alias it will be resolved
      #   and a true token (target) will be returned.
      #   @param [Symbol,String] token the identifier of the checked token
      #   @param [Symbol,String] kind the identifier of a kind
      #   @return [Symbol,nil] the true token or +nil+
      # @overload true_token(token, kind, locale)
      #   Uses the given +locale+ and +kind+ to get a real token
      #   for the given +token+. If the token is an alias it will be resolved
      #   and a true token (target) will be returned.
      #   @param [Symbol,String] token the identifier of the checked token
      #   @param [Symbol,String] kind the identifier of a kind
      #   @param [Symbol] locale the locale to use
      #   @return [Symbol,nil] the true token or +nil+
      def true_token(*args)
        token, kind, locale = tkl_args(args)
        return nil if (token.nil? || kind.nil?)
        data_safe(locale).get_true_token(token, kind)
      end
      alias_method :resolve_alias, :true_token

      # Gets a kind of the given +token+ (which may be an alias) belonging to a strict kind.
      # 
      # @api public
      # @return [Symbol,nil] the kind of the given +token+ or +nil+
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload kind(token, kind)
      #   Uses current locale and the given +kind+ to get a kind of
      #   the given +token+ (which may be an alias).
      #   @param [Symbol,String] token name of the token or alias
      #   @param [Symbol,String] kind the identifier of a kind (expectations filter)
      #   @return [Symbol,nil] the kind of the given +token+ or +nil+
      # @overload kind(token, kind, locale)
      #   Uses the given +locale+ to get a kind of the given +token+ (which may be an alias).
      #   @param [Symbol,String] token name of the token or alias
      #   @param [Symbol,String] kind the identifier of a kind (expectations filter)
      #   @param [Symbol] locale the locale to use
      #   @return [Symbol,nil] the kind of the given +token+ or +nil+
      def kind(token, kind=nil, locale=nil)
        return nil if (token.nil? || kind.nil? || token.to_s.empty? || kind.to_s.empty?)
        data_safe(locale).get_kind(token.to_sym, kind.to_sym)
      end

      # Iterates through available inflection tokens belonging to a strict kind and their descriptions.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      # @yield [token, description] optional block in which each token will be yielded
      # @yieldparam [Symbol] token a token
      # @yieldparam [String] description a description string for a token
      # @yieldreturn [LazyHashEnumerator] the lazy enumerator
      # @note You cannot deduce where aliases are pointing to, since the information
      #   about a target is replaced by the description. To get targets use the
      #   {#raw_tokens} method. To simply list aliases and their targets use
      #   the {#aliases} method.
      # @overload each_token(kind)
      #   Iterates through available inflection tokens and their descriptions for some +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      # @overload each_token(kind, locale)
      #   Iterates through available inflection tokens and their descriptions of the given
      #   +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      def each_token(kind=nil, locale=nil, &block)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        data_safe(locale).each_token(kind, &block)
      end

      # Gets available inflection tokens belonging to a strict kind and their descriptions.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [Hash] the hash containing available inflection tokens and descriptions
      # @note You cannot deduce where aliases are pointing to, since the information
      #   about a target is replaced by the description. To get targets use the
      #   {#raw_tokens} method. To simply list aliases and their targets use
      #   the {#aliases} method.
      # @overload tokens(kind)
      #   Gets available inflection tokens and their descriptions for some +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [Hash] the hash containing available inflection tokens (including
      #     aliases) as keys and their descriptions as values
      # @overload tokens(kind, locale)
      #   Gets available inflection tokens and their descriptions of the given
      #   +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [Hash] the hash containing available inflection tokens (including
      #     aliases) as keys and their descriptions as values
      def tokens(kind=nil, locale=nil)
        each_token(kind, locale).to_h
      end

      # Iterates through available inflection tokens belonging to a strict kind and their values.
      # 
      # @api public
      # @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description|target</tt>)
      # @yield [token, value] optional block in which each token will be yielded
      # @yieldparam [Symbol] token a token
      # @yieldparam [Symbol, String] value a description string for a token or a target (if alias)
      # @yieldreturn [LazyHashEnumerator] the lazy enumerator
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @note You may deduce whether the returned values are aliases or true tokens
      #   by testing if a value is a kind of Symbol or a String.
      # @overload each_token_raw(kind)
      #   Iterates through available inflection tokens and their values of the given +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description|target</tt>)
      # @overload each_token_raw(kind, locale)
      #   Iterates through available inflection tokens (and their values) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description|target</tt>)
      def each_token_raw(kind=nil, locale=nil, &block)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        data_safe(locale).each_raw_token(kind, &block)
      end
      alias_method :each_raw_token, :each_token_raw

      # Gets available inflection tokens belonging to a strict kind and their values.
      # 
      # @api public
      # @return [Hash] the hash containing available inflection tokens and descriptions (or alias pointers)
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @note You may deduce whether the returned values are aliases or true tokens
      #   by testing if a value is a kind of Symbol or a String.
      # @overload tokens_raw(kind)
      #   Gets available inflection tokens and their values of the given +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [Hash] the hash containing available inflection tokens as keys
      #     and their descriptions as values; in case of aliases the returned
      #     values are Symbols
      # @overload tokens_raw(kind, locale)
      #   Gets available inflection tokens (and their values) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [Hash] the hash containing available inflection tokens as keys
      #     and their descriptions as values. In case of aliases the returned
      #     values are Symbols
      def tokens_raw(kind=nil, locale=nil)
        each_token_raw(kind, locale).to_h
      end
      alias_method :raw_tokens, :tokens_raw

      # Iterates through inflection tokens belonging to a strict kind and their values.
      # 
      # @api public
      # @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      # @yield [token, description] optional block in which each token will be yielded
      # @yieldparam [Symbol] token a token
      # @yieldparam [String] description a description string for a token
      # @yieldreturn [LazyHashEnumerator] the lazy enumerator
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @note It returns only true tokens, not aliases.
      # @overload each_token_true(kind)
      #   Iterates through true inflection tokens (and their values) of the given +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      # @overload each_token_true(kind, locale)
      #   Iterates through true inflection tokens (and their values) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => description</tt>)
      def each_token_true(kind=nil, locale=nil, &block)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        data_safe(locale).each_true_token(kind, &block)
      end
      alias_method :each_true_token, :each_token_true

      # Gets true inflection tokens belonging to a strict kind and their values.
      # 
      # @api public
      # @return [Hash] the hash containing available inflection tokens and descriptions
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @note It returns only true tokens, not aliases.
      # @overload tokens_true(kind)
      #   Gets true inflection tokens (and their values) of the given +kind+ and
      #   the current locale.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @return [Hash] the hash containing available inflection tokens as keys
      #     and their descriptions as values
      # @overload tokens_true(kind, locale)
      #   Gets true inflection tokens (and their values) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of inflection tokens to be returned
      #   @param [Symbol] locale the locale to use
      #   @return [Hash] the hash containing available inflection tokens as keys
      #     and their descriptions as values
      def tokens_true(kind=nil, locale=nil)
        each_token_true(kind, locale).to_h
      end
      alias_method :true_tokens, :tokens_true

      # Iterates through inflection aliases belonging to a strict kind and their pointers.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [LazyHashEnumerator] the lazy enumerator (<tt>token => target</tt>)
      # @yield [alias, target] optional block in which each alias will be yielded
      # @yieldparam [Symbol] alias an alias
      # @yieldparam [Symbol] target a name of the target token
      # @yieldreturn [LazyHashEnumerator] the lazy enumerator
      # @overload each_alias(kind)
      #   Iterates through inflection aliases (and their pointers) of the given +kind+ and the current locale.
      #   @param [Symbol,String] kind the kind of aliases to get
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => target</tt>)
      # @overload each_alias(kind, locale)
      #   Iterates through inflection aliases (and their pointers) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of aliases to get
      #   @param [Symbol] locale the locale to use
      #   @return [LazyHashEnumerator] the lazy enumerator (<tt>token => target</tt>)
      def each_alias(kind=nil, locale=nil, &block)
        kind = kind.to_s.empty? ? nil : kind.to_sym
        data_safe(locale).each_alias(kind, &block)
      end

      # Gets inflection aliases belonging to a strict kind and their pointers.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [Hash] the Hash containing available inflection aliases (<tt>alias => target</tt>)
      # @overload aliases(kind)
      #   Gets inflection aliases (and their pointers) of the given +kind+ and the current locale.
      #   @param [Symbol,String] kind the kind of aliases to get
      #   @return [Hash] the Hash containing available inflection aliases
      # @overload aliases(kind, locale)
      #   Gets inflection aliases (and their pointers) of the given +kind+ and +locale+.
      #   @param [Symbol,String] kind the kind of aliases to get
      #   @param [Symbol] locale the locale to use
      #   @return [Hash] the Hash containing available inflection aliases
      def aliases(kind=nil, locale=nil)
        each_alias(kind, locale).to_h
      end

      # Gets the description of the given inflection token belonging to a strict kind.
      # 
      # @api public
      # @note If the given +token+ is really an alias it
      #   returns the description of the true token that
      #   it points to.
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [String,nil] the descriptive string or +nil+
      # @overload token_description(token, kind)
      #   Uses the current locale and the given +token+ to get a description of that token.
      #   @param [Symbol,String] token the token
      #   @param [Symbol,String] kind the identifier of a kind
      #   @return [String,nil] the descriptive string or +nil+ if something
      #     went wrong (e.g. token was not found)
      # @overload token_description(token, kind, locale)
      #   Uses the given +locale+ and the given +token+ to get a description of that token.
      #   @param [Symbol,String] token the token
      #   @param [Symbol,String] kind the identifier of a kind
      #   @param [Symbol] locale the locale to use
      #   @return [String,nil] the descriptive string or +nil+ if something
      #     went wrong (e.g. token was not found)
      def token_description(*args)
        token, kind, locale = tkl_args(args)
        return nil if (token.nil? || kind.nil?)
        data_safe(locale).get_description(token, kind)
      end

      protected

      # @private
      def data(locale=nil)
        @idb[prep_locale(locale)]
      end

      # @private
      def data_safe(locale=nil)
        @idb[prep_locale(locale)] || I18n::Inflector::InflectionData_Strict.new(locale)
      end

      # This method is the internal helper that prepares arguments
      # containing +token+, +kind+ and +locale+.
      # 
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @raise [ArgumentError] if the count of arguments is invalid
      # @return [Array<Symbol,Symbol,Symbol>] the array containing
      #   cleaned and validated +token+, +kind+ and +locale+
      # @overload tkl_args(token, kind, locale)
      #   Prepares arguments containing +token+, +kind+ and +locale+.
      #   @param [String,Hash] token the token
      #   @param [String,Hash] kind the inflection kind
      #   @param [String,Hash] locale the locale identifier
      #   @return [Array<Symbol,Symbol,Symbol>] the array containing
      #     cleaned and validated +token+, +kind+ and +locale+
      # @overload tkl_args(token, kind)
      #   Prepares arguments containing +token+ and +locale+.
      #   @param [String,Hash] token the token
      #   @param [String,Hash] kind the inflection kind
      #   @return [Array<Symbol,Symbol,Symbol>] the array containing
      #     cleaned and validated +token+, +kind+ and +locale+
      # @overload tkl_args(token)
      #   Prepares arguments containing +token+.
      #   @param [String,Hash] token the token
      #   @return [Array<Symbol,Symbol,Symbol>] the array containing
      #     cleaned and validated +token+ and the current locale
      def tkl_args(args)
        token, kind, locale = case args.count
        when 1 then [args[0], nil, nil]
        when 2 then [args[0], args[1], nil]
        when 3 then args
        else raise I18n::ArgumentError.new("wrong number of arguments: #{args.count} for (1..3)")
        end
        token = token.nil? || token.to_s.empty? ? nil : token.to_sym
        kind  = kind.nil?  || kind.to_s.empty?  ? nil : kind.to_sym
        [token,kind,locale]
      end

      # Processes +locale+ identifier and validates
      # whether it's correct (not empty and not +nil+).
      # 
      # @note If the +locale+ is not correct, it
      #   tries to use locale from {I18n.locale} and validates it
      #   as well.
      # @param [Symbol,String] locale the locale identifier
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @return [Symbol] the given locale or the global locale
      def prep_locale(locale=nil)
        locale ||= I18n.locale
        raise I18n::InvalidLocale.new(locale) if locale.to_s.empty?
        locale.to_sym
      end

    end # class API_Strict

  end # module Inflector
end # module I18n

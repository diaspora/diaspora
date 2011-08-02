# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains I18n::Backend::Inflector module,
# which extends I18n::Backend::Simple by adding the ability
# to interpolate patterns containing inflection tokens
# defined in translation data.

module I18n

  # @abstract This namespace is shared with I18n subsystem.
  module Backend

    # This module contains methods that add
    # tokenized inflection support to internal I18n classes.
    # It is intened to be included in the Simple backend
    # module so that it will patch translate method in order
    # to interpolate additional inflection tokens present in translations.
    # Usually you don't have to know what's here to use it.
    module Inflector

      # Shortcut to configuration module.
      InflectorCfg = I18n::Inflector::Config

      # This accessor allows to reach API methods of the
      # inflector object associated with this class.
      def inflector
        inflector_try_init
        @inflector
      end

      # Cleans up internal hashes containg kinds, inflections and aliases.
      # 
      # @api public
      # @note It calls {I18n::Backend::Simple#reload! I18n::Backend::Simple#reload!}
      # @return [Boolean] the result of calling ancestor's method
      def reload!
        @inflector = nil
        super
      end

      # Translates given key taking care of inflections.
      # 
      # @api public
      # @see I18n::Inflector::API#interpolate
      # @see I18n::Inflector::InflectionOptions
      # @param [Symbol] locale locale
      # @param [Symbol,String] key translation key
      # @param [Hash] options a set of options to pass to the translation routines.
      # @note The given +options+ along with a translated string and the given
      #   +locale+ are passed to
      #   {I18n::Backend::Simple#translate I18n::Backend::Simple#translate}
      #   and then the result is processed by {I18n::Inflector::API#interpolate}
      # @return [String] the translated string with interpolated patterns
      def translate(locale, key, options = {})
        inflector_try_init

        # take care about cache-awareness
        cached = options.has_key?(:inflector_cache_aware) ?
                 options[:inflector_cache_aware] : @inflector.options.cache_aware

        if cached
          interpolate_options = options
          @inflector.options.prepare_options!(options)
        else
          interpolate_options = options.dup
          @inflector.options.clean_for_translate!(options)
        end

        # translate string using original translate
        translated_string = super

        # generate a pattern from key-based inflection object
        if (translated_string.is_a?(Hash) && key.to_s[0..0] == InflectorCfg::Markers::STRICT_KIND)
          translated_string = @inflector.key_to_pattern(translated_string)
        end

        # interpolate string
        begin

          @inflector.options.prepare_options!(interpolate_options) unless cached
          @inflector.interpolate(translated_string, locale, interpolate_options)

        # complete the exception by adding translation key
        rescue I18n::InflectionException => e

          e.key = key
          raise

        end

      end

      # Stores translations in memory.
      # 
      # @api public
      # @raise [I18n::InvalidLocale] if the given +locale+ is invalid
      # @raise [I18n::BadInflectionToken] if a name of some loaded token is invalid
      # @raise [I18n::BadInflectionAlias] if a loaded alias points to a token that does not exists
      # @raise [I18n::BadInflectionKind] if a loaded kind identifier is invalid
      # @raise [I18n::DuplicatedInflectionToken] if a token has already appeard in loaded configuration
      # @note If inflections are changed it will regenerate proper internal
      #   structures.
      # @return [Hash] the stored translations 
      def store_translations(locale, data, options = {})
        r = super
        inflector_try_init
        if data.respond_to?(:has_key?)
          subdata = (data[:i18n] || data['i18n'])
          unless subdata.nil?
            subdata = (subdata[:inflections] || subdata['inflections'])
            unless subdata.nil?
              db, db_strict = load_inflection_tokens(locale, r[:i18n][:inflections])
              @inflector.add_database(db, db_strict)
            end
          end
        end
        r
      end

      protected

      # Initializes internal hashes used for keeping inflections configuration.
      # 
      # @return [void]
      def inflector_try_init
        unless (defined?(@inflector) && !@inflector.nil?)
          @inflector = I18n::Inflector::API.new
          init_translations unless initialized?
        end
      end

      # Takes care of loading inflection tokens
      # for all languages (locales) that have them
      # defined.
      # 
      # @note It calls {I18n::Backend::Simple#init_translations I18n::Backend::Simple#init_translations}
      # @raise [I18n::BadInflectionToken] if a name of some loaded token is invalid
      # @raise [I18n::BadInflectionAlias] if a loaded alias points to a token that does not exists
      # @raise [I18n::BadInflectionKind] if a loaded kind identifier is invalid
      # @raise [I18n::DuplicatedInflectionToken] if a token has already appeard in loaded configuration
      # @return [Boolean] +true+ if everything went fine
      def init_translations
        unless (defined?(@inflector) && !@inflector.nil?)
          @inflector = I18n::Inflector::API.new
        end
        super
      end

      # Gives an access to the internal structure containing configuration data
      # for the given locale.
      # 
      # @note Under some very rare conditions this method may be called while
      #   translation data is loading. It must always return when translations
      #   are not initialized. Otherwise it will cause loops and someone in Poland
      #   will eat a kittien!
      # @param [Symbol] locale the locale to use
      # @return [Hash,nil] part of the translation data that
      #   reflects inflections for the given locale or +nil+
      #   if translations are not initialized
      def inflection_subtree(locale)
        return nil unless initialized?
        lookup(locale, :"i18n.inflections", [], :fallback => true, :raise => :false)
      end

      # Resolves an alias for a token if the given +token+ is an alias.
      # 
      # @note It does take care of aliasing loops (max traverses is set to 64).
      # @raise [I18n::BadInflectionToken] if a name of the token that alias points to is corrupted
      # @raise [I18n::BadInflectionAlias] if an alias points to token that does not exists
      # @return [Symbol] the true token that alias points to if the given +token+
      #   is an alias or the given +token+ if it is a true token
      # @overload shorten_inflection_alias(token, kind, locale)
      #   Resolves an alias for a token if the given +token+ is an alias for the given +locale+ and +kind+.
      #   @note This version uses internal subtree and needs the translation data to be initialized.
      #   @param [Symbol] token the token name
      #   @param [Symbol] kind the kind of the given token
      #   @param [Symbol] locale the locale to use
      #   @return [Symbol] the true token that alias points to if the given +token+
      #     is an alias or the given +token+ if it is a true token
      # @overload shorten_inflection_alias(token, kind, locale, subtree)
      #   Resolves an alias for a token if the given +token+ is an alias for the given +locale+ and +kind+.
      #   @param [Symbol] token the token name
      #   @param [Symbol] kind the kind of the given token
      #   @param [Symbol] locale the locale to use
      #   @param [Hash] subtree the tree (in a form of nested Hashes) containing inflection tokens to scan
      #   @return [Symbol] the true token that alias points to if the given +token+
      #     is an alias or the given +token+ if it is a true token
      def shorten_inflection_alias(token, kind, locale, subtree=nil, count=0)
        count += 1
        return nil if count > 64

        inflections_tree = subtree || inflection_subtree(locale)
        return nil if (inflections_tree.nil? || inflections_tree.empty?)

        kind_subtree  = inflections_tree[kind]
        value         = kind_subtree[token].to_s

        if value[0..0] != InflectorCfg::Markers::ALIAS
          if kind_subtree.has_key?(token)
            return token
          else
            raise I18n::BadInflectionToken.new(locale, token, kind)
          end
        else
          orig_token = token
          token = value[1..-1]

          if InflectorCfg::Reserved::Tokens.invalid?(token, :DB)
            raise I18n::BadInflectionToken.new(locale, token, kind)
          end

          token = token.to_sym
          if kind_subtree[token].nil?
            raise BadInflectionAlias.new(locale, orig_token, kind, token)
          else
            shorten_inflection_alias(token, kind, locale, inflections_tree, count)
          end
        end

      end

      # Uses the inflections subtree and creates internal mappings
      # to resolve kinds assigned to inflection tokens and aliases, including defaults.
      # @return [I18n::Inflector::InflectionData,nil] the database containing inflections tokens
      #   or +nil+ if something went wrong
      # @raise [I18n::BadInflectionToken] if a token identifier is invalid
      # @raise [I18n::BadInflectionKind] if a kind identifier is invalid
      # @raise [I18n::BadInflectionAlias] if a loaded alias points to a token that does not exists
      # @raise [I18n::DuplicatedInflectionToken] if a token has already appeard in loaded configuration
      # @overload load_inflection_tokens(locale)
      #   @note That version calls the {inflection_subtree} method to obtain internal translations data.
      #   Loads inflection tokens for the given locale using internal hash of stored translations. Requires
      #   translations to be initialized.
      #   @param [Symbol] locale the locale to use and work for
      #   @return [I18n::Inflector::InflectionData,nil] the database containing inflections tokens
      #     or +nil+ if something went wrong
      # @overload load_inflection_tokens(locale, subtree)
      #   Loads inflection tokens for the given locale using datthe given in an argument
      #   @param [Symbol] locale the locale to use and work for
      #   @param [Hash] subtree the tree (in a form of nested Hashes) containing inflection tokens to scan
      #   @return [I18n::Inflector::InflectionData,nil] the database containing inflections tokens
      #     or +nil+ if something went wrong
      def load_inflection_tokens(locale, subtree=nil)
        inflections_tree = subtree || inflection_subtree(locale)
        return nil if (inflections_tree.nil? || inflections_tree.empty?)

        idb         = I18n::Inflector::InflectionData.new(locale)
        idb_strict  = I18n::Inflector::InflectionData_Strict.new(locale)

        return nil if (idb.nil? || idb_strict.nil?)

        inflections = prepare_inflections(locale, inflections_tree, idb, idb_strict)

        inflections.each do |orig_kind, kind, strict_kind, subdb, tokens|

          # validate token's kind
          if (kind.to_s.empty? || InflectorCfg::Reserved::Kinds.invalid?(orig_kind, :DB))
            raise I18n::BadInflectionKind.new(locale, orig_kind)
          end

          tokens.each_pair do |token, description|

            # test for duplicate
            if subdb.has_token?(token, strict_kind)
              raise I18n::DuplicatedInflectionToken.new(locale, token, orig_kind,
                                                        subdb.get_kind(token, strict_kind))
            end

            # validate token's name
            if InflectorCfg::Reserved::Tokens.invalid?(token, :DB)
              raise I18n::BadInflectionToken.new(locale, token, orig_kind)
            end

            # validate token's description
            if description.nil?
              raise I18n::BadInflectionToken.new(locale, token, orig_kind, description)
            elsif description.to_s[0..0] == InflectorCfg::Markers::ALIAS
              next
            end

            # skip default token for later processing
            next if token == :default

            subdb.add_token(token, kind, description)
          end
        end

        # handle aliases
        inflections.each do |orig_kind, kind, strict_kind, subdb, tokens|
          tokens.each_pair do |token, description|
            next if token == :default
            next if description.to_s[0..0] != InflectorCfg::Markers::ALIAS
            real_token = shorten_inflection_alias(token, orig_kind, locale, inflections_tree)
            subdb.add_alias(token, real_token, kind) unless real_token.nil?
          end
        end

        # handle default tokens
        inflections.each do |orig_kind, kind, strict_kind, subdb, tokens|
          next unless tokens.has_key?(:default)
          if subdb.has_default_token?(kind)
            raise I18n::DuplicatedInflectionToken.new(locale, :default, kind, orig_kind)
          end
          orig_target = tokens[:default]
          target = orig_target.to_s
          target = target[1..-1] if target[0..0] == InflectorCfg::Markers::ALIAS
          if target.empty?
            raise I18n::BadInflectionToken.new(locale, token, orig_kind, orig_target)
          end
          target = subdb.get_true_token(target.to_sym, kind)
          if target.nil?
            raise I18n::BadInflectionAlias.new(locale, :default, orig_kind, orig_target)
          end
          subdb.set_default_token(kind, target)
        end

        [idb, idb_strict]
      end

      # @private
      def prepare_inflections(locale, inflections, idb, idb_strict)
        unless inflections.respond_to?(:has_key?)
          raise I18n::BadInflectionKind.new(locale, :INFLECTIONS_ROOT)
        end
        I18n::Inflector::LazyHashEnumerator.new(inflections).ary_map do |kind, tokens|
          next if (tokens.nil? || tokens.empty?)
          unless tokens.respond_to?(:has_key?)
            raise I18n::BadInflectionKind.new(locale, kind)
          end
          subdb       = idb
          strict_kind = nil
          orig_kind   = kind
          if kind.to_s[0..0] == InflectorCfg::Markers::STRICT_KIND
            kind        = kind.to_s[1..-1]
            next if kind.empty?
            kind        = kind.to_sym
            subdb       = idb_strict
            strict_kind = kind
          end
          [orig_kind, kind, strict_kind, subdb, tokens]
        end
      end

    end # module Inflector
  end # module Backend
end # module I18n

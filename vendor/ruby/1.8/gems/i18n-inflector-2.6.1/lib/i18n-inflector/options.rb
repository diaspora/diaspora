# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains a class used to set up some options,
# for engine.

module I18n
  module Inflector

    # This class contains structures for keeping parsed translation data
    # and basic operations.
    # 
    # All global options are available for current backend's inflector by
    # calling:
    #   I18n.backend.inflector.options.<option_name>
    # or just:
    #   I18n.inflector.options.<option_name>
    # A global option may be overriden by passing a proper option to
    # the translation method. Such option should have the name of a
    # global option but prefixed with +inflector_+:
    #   translate('welcome', :inflector_<option_name> => value)
    # @note This class uses modified version of +attr_accessor+ that
    #   memorizes any added method name as an option name. These options
    #   (with +inflector_+ prefix added) are accessible through
    #   {#known} method. The last method is used by options preparing
    #   routine when the interpolation is performed.
    class InflectionOptions

      # Prefix used to mark option as a controlling option.
      OPTION_PREFIX = 'inflector_'

      class <<self

        # @private
        def known
          @known
        end

        # @private
        alias old_attr_accessor attr_accessor
        def attr_accessor(*args)
          r = old_attr_accessor(*args)
          @known ||= Hash.new
          args.each do |arg|
            key = '@' << arg.to_s
            @known[key.to_sym] = ("" << OPTION_PREFIX << arg.to_s).to_sym
          end
          r
        end

      end

      # This switch enables cache-aware mode. In that mode inflection
      # options and flags are evaluated before calling original translate
      # method and all options are passed to that method. Because options
      # preparation for inflection methods is explicit (any missing switches
      # and their default values are added to options) then original
      # translate (or proxy caching method) will receive even those options
      # that might have been changed globally.
      # 
      # Caching modules for I18n may use options passed to the translate
      # method (if they are plugged in before inflector) for key
      # transformation since the inflection options may influence
      # the interpolation process and therefore the resulting string.
      # 
      # If however, the caching variant of the translate method is
      # positioned before inflected variant in methods chain, then
      # the only way of knowing all the settings by caching routine is to call
      # <tt>options.options.prepare_options!(options)</tt> on the used backend,
      # for example:
      #   I18n.backend.inflector.options.prepare(options)
      # That will alter the +options+ data so they will contain all switches
      # and values.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      attr_accessor :cache_aware

      # This is a switch that enables extended error reporting. When it's enabled then
      # errors are raised in case of unknown or empty tokens present in a pattern
      # or in options. This switch is by default set to +false+.
      # 
      # @note Local option +:inflector_raises+ passed
      #   to the {I18n::Backend::Inflector#translate} overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      attr_accessor :raises

      # This is a switch that enables you to use aliases in patterns. When it's enabled then
      # aliases may be used in inflection patterns, not only true tokens. This operation
      # may make your translation data a bit messy if you're not alert.
      # That's why this switch is by default set to +false+.
      # 
      # @note Local option +:inflector_aliased_patterns+ passed to the
      #   {I18n::Backend::Inflector#translate} overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      attr_accessor :aliased_patterns

      # This is a switch that enables you to interpolate patterns contained
      # in resulting nested Hashes. It is used when the original translation
      # method returns a subtree of translation data because the given key
      # is not pointing to a leaf of the data but to some collection.
      # 
      # This switch is by default set to +true+. When you turn it off then
      # the Inflector won't touch nested results and will return them as they are.
      # 
      # @note Local option +:inflector_traverses+ passed to the
      #   {I18n::Backend::Inflector#translate} overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      attr_accessor :traverses

      # This is a switch that enables interpolation of symbols. Whenever
      # interpolation method will receive a collection of symbols as a result
      # of calling underlying translation method
      # it won't process them, returning as they are, unless
      # this switch is enabled.
      # 
      # Note that using symbols as values in translation data creates
      # I18n aliases. This option is intended to work with arrays of
      # symbols or hashes with symbols as values, if the original translation
      # method returns such structures.
      # 
      # This switch is by default set to +false+.
      # 
      # @note Local option +:inflector_interpolate_symbols+ passed to the
      #   {I18n::Backend::Inflector#translate} overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      attr_accessor :interpolate_symbols

      # When this switch is set to +true+ then inflector falls back to the default
      # token for a kind if an inflection option passed to the
      # {I18n::Backend::Inflector#translate} is unknown or +nil+.
      # Note that the value of the default token will be
      # interpolated only when this token is present in a pattern. This switch
      # is by default set to +true+.
      # 
      # @note Local option +:inflector_unknown_defaults+ passed
      #   to the {I18n::Backend::Inflector#translate} overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      # 
      # @example YAML:
      #    en:
      #     i18n:
      #       inflections:
      #         gender:
      #           n:       'neuter'
      #           o:       'other'
      #           default:  n
      # 
      #     welcome:         "Dear @{n:You|o:Other}"
      #     welcome_free:    "Dear @{n:You|o:Other|Free}"
      #   
      # @example Example 1
      #   
      #   # :gender option is not present,
      #   # unknown tokens in options are falling back to default
      #    
      #   I18n.t('welcome')
      #   # => "Dear You"
      #   
      #   # :gender option is not present,
      #   # unknown tokens from options are not falling back to default
      #   
      #   I18n.t('welcome', :inflector_unknown_defaults => false)
      #   # => "Dear You"
      # 
      #   # other way of setting an option – globally
      #   
      #   I18n.inflector.options.unknown_defaults = false
      #   I18n.t('welcome')
      #   # => "Dear You"
      #   
      #   # :gender option is not present, free text is present,
      #   # unknown tokens from options are not falling back to default
      #   
      #   I18n.t('welcome_free', :inflector_unknown_defaults => false)
      #   # => "Dear You"
      #   
      # @example Example 2
      #   
      #   # :gender option is nil,
      #   # unknown tokens from options are falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => nil)
      #   # => "Dear You"
      #   
      #   # :gender option is nil
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => nil, :inflector_unknown_defaults => false)
      #   # => "Dear "
      #   
      #   # :gender option is nil, free text is present
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome_free', :gender => nil, :inflector_unknown_defaults => false)
      #   # => "Dear Free"
      # 
      # @example Example 3
      #   
      #   # :gender option is unknown,
      #   # unknown tokens from options are falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => :unknown_blabla)
      #   # => "Dear You"
      #   
      #   # :gender option is unknown,
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome', :gender => :unknown_blabla, :inflector_unknown_defaults => false)
      #   # => "Dear "
      #   
      #   # :gender option is unknown, free text is present
      #   # unknown tokens from options are not falling back to default token for a kind
      #   
      #   I18n.t('welcome_free', :gender => :unknown_blabla, :inflector_unknown_defaults => false)
      #   # => "Dear Free"
      attr_accessor :unknown_defaults

      # When this switch is set to +true+ then inflector falls back to the default
      # token for a kind if the given inflection option is correct but doesn't exist
      # in a pattern.
      # 
      # There might happen that the inflection option
      # given to {#translate} method will contain some proper token, but that token
      # will not be present in a processed pattern. Normally an empty string will
      # be generated from such a pattern or a free text (if a local fallback is present
      # in a pattern). You can change that behavior and tell interpolating routine to
      # use the default token for a processed kind in such cases.
      # 
      # This switch is by default set to +false+.
      # 
      # @note Local option +:inflector_excluded_defaults+ passed to the {I18n::Backend::Inflector#translate}
      #   overrides this setting.
      # 
      # @api public
      # @return [Boolean] state of the switch
      # @param [Boolean] state +true+ enables, +false+ disables this switch
      # 
      # @example YAML:
      #   en:
      #     i18n:
      #       inflections:
      #         gender:
      #           o:      "other"
      #           m:      "male"
      #           n:      "neuter"
      #           default: n
      #   
      #     welcome:  'Dear @{n:You|m:Sir}'
      # @example Usage of +:inflector_excluded_defaults+ option
      #   I18n.t('welcome', :gender => :o)
      #   # => "Dear "
      #   
      #   I18n.t('welcome', :gender => :o, :inflector_excluded_defaults => true)
      #   # => "Dear You"
      attr_accessor :excluded_defaults

      # This method initializes all internal structures.
      def initialize
        reset
      end

      # This method resets all options to their default values.
      # 
      # @return [void]
      def reset
        @unknown_defaults   = true
        @traverses          = true
        @interpolate_symbols= false
        @excluded_defaults  = false
        @aliased_patterns   = false
        @cache_aware        = false
        @raises             = false
        nil
      end

      # This method processes the given argument
      # in a way that it will use default values
      # for options that are missing.
      # 
      # @api public
      # @note It modifies the given object.
      # @param [Hash] options the options
      # @return [Hash] the given options
      def prepare_options!(options)
        self.class.known.
        reject { |name,long| options.has_key?(long) }.
        each   { |name,long| options[long] = instance_variable_get(name) }
        options
      end

      # This method prepares options for translate method.
      # That means removal of all kind-related options
      # and all options that are flags.
      # 
      # @api public
      # @note It modifies the given object.
      # @param [Hash] options the given options
      # @return [Hash] the given options
      def clean_for_translate!(options)
        self.class.known.each { |name,long| options.delete long }
        options
      end

      # Lists all known options in a long format
      # (each name preceeded by <tt>inflector_</tt>).
      # 
      # @api public
      # @return [Array<Symbol>] the known options
      def known
        self.class.known.values
      end

    end

  end
end

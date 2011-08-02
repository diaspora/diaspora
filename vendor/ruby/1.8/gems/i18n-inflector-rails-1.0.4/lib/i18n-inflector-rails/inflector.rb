# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains I18n::Backend::Inflector::Rails module,
# which extends ActionView::Helpers::TranslationHelper
# by adding the ability to interpolate patterns containing
# inflection tokens defined in translation data.

module I18n

  # @abstract It is defined in {I18n Inflector library}[http://rubydoc.info/gems/i18n-inflector].
  module Inflector
    module Rails

      # This module contains instance methods for ActionController.
      module InstanceMethods

        # This method calls the class method {I18n::Inflector::Rails::ClassMethods#i18n_inflector_kinds}
        def i18n_inflector_kinds
          self.class.i18n_inflector_kinds
        end

        # @private
        def self.included(base)
          base.helper_method(:i18n_inflector_kinds)
        end

      end # instance methods

      # This module contains class methods for ActionController.
      module ClassMethods

        # This method reads the internal Hash +i18n_inflector_kinds+ containing registered
        # inflection methods and the assigned kinds. It also reads any methods
        # assignments that were defined earlier in the inheritance path and
        # merges them with current results; the most current entries will
        # override the entries defined before.
        # 
        # @api public
        # @return [Hash] the Hash containing assignments made by using {#inflection_method}
        def i18n_inflector_kinds
          prev = superclass.respond_to?(:i18n_inflector_kinds) ? superclass.i18n_inflector_kinds : {}
          return @i18n_inflector_kinds.nil? ? prev : prev.merge(@i18n_inflector_kinds)
        end

        # This method allows to assign methods (typically attribute readers)
        # to inflection kinds that are defined in translation files and
        # supported by {I18n::Inflector} module. Methods registered like that
        # will be tracked when {translate} is used and their returning values will be
        # passed as inflection options along with assigned kinds. If the kind is not
        # given then method assumes that the name of a kind is the same as the given
        # name of a method.
        # 
        # If the given kind begins with +@+ then strict kind is assumed. If there is
        # no kind given but the given method name begins with +@+ character then
        # also strict kind of the same name is assumed but method name is memorized
        # without the leading symbol.
        # 
        # Registering method for feeding an inflection option describing a strict
        # kind might be good idea when using some regular kind of the same name,
        # but note that regular kind inflection option is also tried by the
        # translation method when strict kind is in use.
        # 
        # In case of registering two methods of different
        # names but assigned to kind and to a strict kind using the same base name,
        # a named inflection pattern will first use an inflection option obtained
        # from a method assigned to a strict kind. Note that it is impossible
        # to use short formed +inflection_method+ calls to register a method for both
        # strict and regular inflection kind, since the method names will be the
        # same and the second call will overwrite the first one.
        # 
        # @example Registering an inflection method for the kind gender visible in a whole application
        #   class ApplicationController < ActionController::Base
        #     inflection_method :gender
        #     […]
        #   end
        # 
        # @example Registering an inflection method for the strict kind @gender visible in a whole application
        #   class ApplicationController < ActionController::Base
        #     inflection_method :@gender
        #     […]
        #   end
        # 
        # @example Registering a custom-named inflection method for the kind gender
        #   class ApplicationController < ActionController::Base
        #     inflection_method :get_user_gender => :gender
        #     […]
        #   end
        # 
        # @example Registering a custom-named inflection methods for the kinds gender and tense
        #   class ApplicationController < ActionController::Base
        #     inflection_method :get_user_gender => :gender, :get_tense => :tense
        #     […]
        #   end
        # 
        # @example Registering inflection methods for the kinds gender and tense
        #   class ApplicationController < ActionController::Base
        #     inflection_method :gender, :tense
        #     […]
        #   end
        # 
        # @example Registering inflection methods for the kind gender and the strict kind @tense
        #   class ApplicationController < ActionController::Base
        #     inflection_method :gender, :@tense
        #     […]
        #   end
        # 
        # @example Registering a custom-named inflection methods for the kinds gender and @gender
        #   # in case of named patterns the method get_strict_gender and the
        #   # strict kind @gender will have priority; the regular kind gender
        #   # and its method would be used if there would be no strict variants
        #   class ApplicationController < ActionController::Base
        #     inflection_method :get_gender => :gender, :get_strict_gender => :@gender
        #     […]
        #   end
        # 
        # @example Registering a method for the kind gender and the custom-named method for the kind @gender
        #   class ApplicationController < ActionController::Base
        #     inflection_method :gender, :get_strict_gender => :@gender
        #     […]
        #   end
        # 
        # @example Registering a method for the kind gender visible in whole app and a variant for some controller
        #   class ApplicationController < ActionController::Base
        #     inflection_method :gender
        #     […]
        #   end
        #   
        #   # In this controller the method gender will be called
        #   # to obtain inflection option's value for the kind gender
        #   class UsersController < ApplicationController
        #   end
        #   
        #   # In this controller the method getit will be called
        #   # to obtain inflection option's value for the kind gender
        #   class OtherController < ApplicationController
        #     inflection_method :getit => :gender
        #   end
        #   
        #   # In this controller no method will be called
        #   # to obtain inflection option's value for the kind gender
        #   class FlowersController < ApplicationController
        #     no_inflection_method :getit
        #   end
        # 
        # @api public
        # @note Any added method will become a helper unless {I18n::Inflector::InflectionOptions#auto_helper} swtich is set to +false+!
        # @raise [I18n::Inflector::Rails::BadInflectionMethod] when the given name or value are malformed
        # @param [Hash{Symbol => Symbol},Array<Symbol>,Symbol,String] *args the methods and inflection kinds assigned to them
        # @return [void]
        def inflection_method(*args)
          args = args.flatten
          if args.empty?
            raise I18n::Inflector::Rails::BadInflectionMethod.new(assignment)
          end

          assignment = {}
          args.each do |e|
            if (e.is_a?(Symbol) || e.is_a?(String))
              assignment[e] = e
            elsif e.is_a?(Hash)
              raise I18n::Inflector::Rails::BadInflectionMethod.new(assignment) if e.empty?
              assignment.merge!(e)
            else
              raise I18n::Inflector::Rails::BadInflectionMethod.new(assignment)
            end
          end

          @i18n_inflector_kinds ||= {}
          assignment.each_pair do |method, kind|
            method = method.to_s
            if (method.empty? || I18n::Inflector::Config::Reserved::Kinds.invalid?(kind, :OPTION))
              raise I18n::Inflector::Rails::BadInflectionMethod.new("#{method.inspect} => #{kind.inspect}")
            end
            kind   = kind.to_s
            method = method[1..-1] if (method[0..0] == I18n::Inflector::Config::Markers::PATTERN && method == kind)
            kind   = kind.to_sym
            method = method.to_sym
            helper_method(method) if I18n.backend.inflector.options.auto_helper
            @i18n_inflector_kinds[kind] = method
          end
        end
        alias_method :inflection_methods, :inflection_method

        # This method unregisters inflection kinds from assignments
        # created by {inflection_method}. It is useful
        # when there is a need to break inheritance in some controller,
        # but there was a method assigned to some inflection kind in
        # a parrent class.
        # 
        # @api public
        # @raise [I18n::Inflector::Rails::BadInflectionMethod] when name or value is bad or malformed
        # @param [Array<Symbol>] names the method names for which the assigned kinds should be marked as not
        #   supported in a current controller and all derivative controllers
        # @return [void]
        def no_inflection_method(*names)
          names = names.flatten
          if (names.nil? || names.empty?)
            raise I18n::Inflector::Rails::BadInflectionMethod.new(names)
          end
          @i18n_inflector_kinds   ||= {}
          names.each do |meth|
            unless (meth.is_a?(Symbol) || meth.is_a?(String))
              raise I18n::Inflector::Rails::BadInflectionMethod.new(meth)
            end
            meth = meth.to_s
            meth = meth[1..-1] if meth[0..0] == I18n::Inflector::Config::Markers::PATTERN # for dummies
            raise I18n::Inflector::Rails::BadInflectionMethod.new(meth) if meth.empty?
            meth = meth.to_sym
            i18n_inflector_kinds.each_pair do |kind, obj|
              if obj == meth
                @i18n_inflector_kinds[kind] = nil
              end
            end
          end
        end
        alias_method :no_inflection_methods, :no_inflection_method

        # This method unregisters the given inflection kinds from assignments
        # created by {inflection_method}. It is useful
        # when there is a need to break inheritance in some controller,
        # but there was a method assigned to some inflection kind in
        # a parrent class.
        # 
        # @api public
        # @raise [I18n::Inflector::Rails::BadInflectionMethod] when name or value is malformed
        # @param [String,Symbol,Array<Symbol>] kinds the kind for which the method names should be marked
        #   as not supported in a current controller and all derivative controllers
        # @return [void]
        def no_inflection_method_for(*names)
          names = names.flatten
          if (names.nil? || names.empty?)
            raise I18n::Inflector::Rails::BadInflectionMethod.new(names)
          end
          @i18n_inflector_kinds ||= {}
          names.each do |kind|
            unless (kind.is_a?(Symbol) || kind.is_a?(String))
              raise I18n::Inflector::Rails::BadInflectionKind.new(kind)
            end
            if (I18n::Inflector::Config::Reserved::Kinds.invalid?(kind, :OPTION) ||
                kind.to_s == I18n::Inflector::Config::Markers::PATTERN)
              raise I18n::Inflector::Rails::BadInflectionKind.new(kind)
            end
            @i18n_inflector_kinds[kind.to_sym] = nil
           end
        end
        alias_method :no_inflection_methods_for, :no_inflection_method_for
        alias_method :no_inflection_kind,        :no_inflection_method_for

      end # class methods

      # This module contains a variant of the +translate+ method that
      # uses {I18n::Inflector::Rails::ClassMethods#i18n_inflector_kinds i18n_inflector_kinds}
      # available in the current context.
      # The method from this module will wrap the
      # {ActionView::Helpers::TranslationHelper#translate} method.
      module InflectedTranslate

        # This method tries to feed itself with the data coming
        # from {I18n::Inflector::Rails::ClassMethods#i18n_inflector_kinds i18n_inflector_kinds}
        # available in the current context.
        # That data contains inflection pairs (<tt>kind => value</tt>) that will
        # be passed to the interpolation method from {I18n::Inflector} through
        # {ActionView::Helpers::TranslationHelper#translate}.
        # 
        # You may also pass inflection options directly, along with other options,
        # without registering methods responsible for delivering tokens.
        # See {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector]
        # for more info about inflection options.
        # 
        # @api public
        # @raise {I18n::InvalidInflectionKind}
        # @raise {I18n::InvalidInflectionOption}
        # @raise {I18n::InvalidInflectionToken}
        # @raise {I18n::MisplacedInflectionToken}
        # @overload translate(key, options)
        #   @param [String] key translation key
        #   @param [Hash] options a set of options to pass to the
        #     translation routines
        #   @option options [Boolean] :inflector_verify_methods (false) local switch
        #     that overrides global setting (see {I18n::Inflector::InflectionOptions#verify_methods})
        #   @option options [Boolean] :inflector_lazy_methods (true) local switch
        #     that overrides global setting (see {I18n::Inflector::InflectionOptions#lazy_methods})
        #   @option options [Boolean] :inflector_excluded_defaults (false) local switch
        #     that overrides global setting (see {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector])
        #   @option options [Boolean] :inflector_unknown_defaults (true) local switch
        #     that overrides global setting (see {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector])
        #   @option options [Boolean] :inflector_raises (false) local switch
        #     that overrides global setting (see {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector])
        #   @option options [Boolean] :inflector_aliased_patterns (false) local switch
        #     that overrides global setting (see {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector])
        #   @option options [Boolean] :inflector_cache_aware (false) local switch
        #     that overrides global setting (see {I18n Inflector documentation}[http://rubydoc.info/gems/i18n-inflector])
        #   @return [String] the translated string with inflection patterns
        #     interpolated
        def translate(*args)
          opts_present  = args.last.is_a?(Hash)
          if opts_present
            options = args.last
            test_locale = options[:locale]
          else
            options = {}
          end
          test_locale ||= I18n.locale
          inflector = I18n.backend.inflector

          # return immediately if the locale is not supported
          return super unless inflector.inflected_locale?(test_locale)

          # collect inflection variables that are present in this context
          subopts  = t_prepare_inflection_options(inflector, locale, options)

          # jump to translate if no inflection options are present
          return super if subopts.empty?

          # pass options and call translate
          args.pop if opts_present
          args.push subopts.merge(options)
          super
        end

        # workaround for Ruby 1.8.x bug
        if RUBY_VERSION.gsub(/\D/,'')[0..1].to_i < 19
          def t(*args); translate(*args) end
        else
          alias_method :t, :translate
        end

        protected

        # This method tries to read +i18n_inflector_kinds+ available in the current context.
        # 
        # @return [Hash] the inflection options (<tt>kind => value</tt>)
        def t_prepare_inflection_options(inflector, locale, options)
          subopts = {}

          verifies = options[:inflector_verify_methods]
          verifies = inflector.options.verify_methods if verifies.nil?
          is_lazy  = options[:inflector_lazy_methods]
          is_lazy  = inflector.options.lazy_methods if is_lazy.nil?

          return subopts if (verifies && !respond_to?(:i18n_inflector_kinds))

          i18n_inflector_kinds.each_pair do |kind, meth|
            next if meth.nil?                                   # kind is registered but disabled from usage
            next if verifies && !respond_to?(meth)
            obj = method(meth)
            obj = obj.call { next kind, locale } unless is_lazy # lazy_methods is disabled
            subopts[kind] = obj
          end
          return subopts
        end

      end # module InflectedTranslate

    end # module Rails
  end # module Inflector
end # module I18n

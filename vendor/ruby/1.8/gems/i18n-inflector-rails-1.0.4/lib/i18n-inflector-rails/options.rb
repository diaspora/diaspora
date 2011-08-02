# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains I18n::Inflector::Rails::AdditionalOptions module,
# which extends I18n::Inflector::InflectionOptions so new switches controlling
# inflector's behavior are available.

module I18n
  module Inflector

    # This module adds options to {I18n::Inflector::InflectionOptions}
    class InflectionOptions

      # When this is set to +true+ then
      # inflection works a bit slower but
      # checks whether any method exists before
      # calling it.
      # 
      # This switch is by default set
      # to +false+.
      # 
      # By turning this switch on you're sure that
      # there will be no +NameError+ (no method) exception
      # raised during translation.
      # 
      # Alternatively you can turn this on locally,
      # for the specified translation call, by setting
      # <tt>:inflector_verify_methods</tt> option to +true+.
      # 
      # @example Globally enabling methods verification
      #   I18n.inflector.options.verify_methods = true
      # @example Locally enabling methods verification
      #   translate('welcome', :inflector_verify_methods => true)
      attr_accessor :verify_methods

      # When this is set to +true+ then
      # each time infleciton method is registered
      # it becomes a helper method so it's available in
      # a view.
      # 
      # This switch is by default set
      # to +true+.
      # 
      # Setting this switch locally,
      # for the specified translation call, using
      # <tt>:inflector_auto_helper</tt> option will
      # have no effect.
      # 
      # @example Globally disabling automatic setting of helpers
      #   I18n.inflector.options.auto_helper = false
      attr_accessor :auto_helper

      # When this is set to +true+ then
      # each time an infleciton method is used to obtain
      # value for the associated kind it evaluates lazy.
      # That means the method object is passed to the
      # translation routines and it is evaluated when there
      # is a need. If this is set to +false+ then
      # evaluation takes place before calling Inflector's
      # translation method and inflection options are passed
      # as symbols, not as method objects.
      # 
      # This switch is by default set
      # to +true+. By disabling it you may experience
      # some negative performance impact when many
      # inflection methods are registered. That is because
      # the lazy evaluation causes calling only those methods
      # that are needed by internal interpolation routines
      # of the Inflector. For instance, if in some pattern
      # only the kind "gender" is used then there is no
      # need to call inflection methods for other kinds.
      # When lazy evaluation is disabled then all inflection
      # methods have to be called before passing control
      # to translation routines, since this plug-in does not
      # analyze contents of inflection patterns or keys.
      # 
      # Alternatively you can turn this off locally,
      # for the specified translation call, by setting
      # <tt>:inflector_lazy_methods</tt> option to +false+.
      # 
      # @example Globally disabling lazy evaluation of kinds
      #   I18n.inflector.options.lazy_methods = false
      # @example Locally disabling lazy evaluation of kinds
      #   translate('welcome', :inflector_lazy_methods => false)
      attr_accessor :lazy_methods

      # @private
      alias_method :_rai_orig_reset, :reset

      # This method resets inflector's
      # switches to default values.
      def reset
        @verify_methods = false
        @auto_helper    = true
        @lazy_methods   = true
        _rai_orig_reset
      end

    end # class InflectionOptions
  end # module Inflector
end # module I18n

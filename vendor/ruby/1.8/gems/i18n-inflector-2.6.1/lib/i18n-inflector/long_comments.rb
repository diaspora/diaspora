# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains inline documentation data
# that would make the file with code less readable
# if placed there. Code from this file is not used
# by the library, it's just for documentation.

module I18n
  module Inflector

    class API

      # This reader allows to reach a reference of the
      # object that is a kind of {I18n::Inflector::API_Strict}
      # and handles inflections for named patterns (strict kinds).
      # 
      # @api public
      # @return [I18n::Inflector::API_Strict] the object containing
      #   database and operations for named patterns (strict kinds)
      attr_reader :strict

      # This reader allows to reach internal configuration
      # of the engine. It is shared among all instances of
      # the Inflector and also available as
      # {I18n::Inflector::Config I18n::Inflector::Config}.
      attr_reader :config

      # Gets known regular inflection kinds.
      # 
      # @api public
      # @note To get all inflection kinds (regular and strict) for default inflector
      #   use: <tt>I18n.inflector.kinds + I18n.inflector.strict.kinds</tt>
      # @return [Array<Symbol>] the array containing known inflection kinds
      # @raise [I18n::InvalidLocale] if there is no proper locale name
      # @overload kinds
      #   Gets known inflection kinds for the current locale.
      #   @return [Array<Symbol>] the array containing known inflection kinds
      # @overload kinds(locale)
      #   Gets known inflection kinds for the given +locale+.
      #   @param [Symbol] locale the locale for which operation has to be done
      #   @return [Array<Symbol>] the array containing known inflection kinds
      def kinds(locale=nil); super end
      alias_method :inflection_kinds, :kinds

    end

  end

  # @abstract This exception class is defined in package I18n. It is raised when
  #   the given and/or processed locale parameter is invalid.
  class InvalidLocale; end

  # @abstract This exception class is defined in package I18n. It is raised when
  #   the given and/or processed translation data or parameter are invalid.
  class ArgumentError; end

end

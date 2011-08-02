# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:docs/LGPL GNU Lesser General Public License} or {file:docs/COPYING Ruby License}.
# 
# This file contains error reporting classes for I18n::Backend::Inflector module.

module I18n

  # @abstract It is a parent class for all exceptions
  #   related to inflections.
  class InflectionException < I18n::ArgumentError

    attr_accessor :token
    attr_accessor :kind
    attr_accessor :key

    def initialize(locale, token, kind)
      @locale, @token, @kind = locale, token, kind
      @key = nil
      super()
    end

  end

  # @abstract It is a parent class for all exceptions
  #   related to inflection patterns that are processed.
  class InflectionPatternException < InflectionException

    attr_accessor :pattern

    def initialize(locale, pattern, token, kind)
      super(locale, token, kind)
      @pattern = pattern
    end

    def message
      mkey = @key.nil? ? "" : ".#{@key}"
      @pattern.nil? ? "" : "#{@locale}#{mkey}: #{@pattern} - "
    end

  end

  # @abstract It is a parent class for all exceptions
  #   related to configuration data of inflections that is processed.
  class InflectionConfigurationException < InflectionException

    attr_accessor :locale

    def message
      mkey = @key.nil? ? ".i18n.inflections.#{@kind}" : ".#{@key}"
      "#{@locale}#{mkey}: "
    end

  end

  # @abstract It is a parent class for exceptions raised when
  #   inflection option is bad or missing.
  class InvalidOptionForKind < InflectionPatternException

    attr_accessor :option

    def initialize(locale, pattern, token, kind, option)
      super(locale, pattern, token, kind)
      @option = option
    end

  end

  # This is raised when there is no kind given in options. The kind
  # is determined by looking at token placed in a pattern.
  class InflectionOptionNotFound < InvalidOptionForKind

    def message
      kind = @kind.to_s
      unless kind.empty?
        if kind[0..0] == I18n::Inflector::Config::Markers::STRICT_KIND
          kindmsg = ":#{kind} (or :#{kind[1..-1]})"
        else
          kindmsg = kind.to_sym.inspect
        end
      end
      "" << super <<
      "required option #{kindmsg} was not found"
    end

  end

  # This exception will be raised when a required option, describing token selected
  # for a kind contains a token that is not of the given kind.
  class InflectionOptionIncorrect < InvalidOptionForKind

    def message
      "" << super <<
      "required value #{@option.inspect} of option #{@kind.inspect} " \
      "does not match any token"
    end

  end

  # This is raised when a token given in a pattern is invalid (empty or has no
  # kind assigned).
  class InvalidInflectionToken < InflectionPatternException

    def initialize(locale, pattern, token, kind=nil)
      super(locale, pattern, token, kind)
    end

    def message
      badkind = ""
      if (!@token.to_s.empty? && !kind.nil?)
        kind = @kind.to_s.empty? ? "" : @kind.to_sym
        badkind = " (processed kind: #{kind.inspect})"
      end
      "" << super << "token #{@token.to_s.inspect} is invalid" + badkind
    end

  end

  # This is raised when an inflection option name is invalid (contains
  # reserved symbols).
  class InvalidInflectionOption < InflectionPatternException

    def initialize(locale, pattern, option)
      super(locale, pattern, nil, option)
    end

    def message
      "" << super << "inflection option #{@kind.inspect} is invalid"
    end

  end

  # This is raised when a kind given in a pattern is invalid (empty, reserved
  # or containing a reserved character).
  class InvalidInflectionKind < InflectionPatternException

    def initialize(locale, pattern, kind)
      super(locale, pattern, nil, kind)
    end

    def message
      "" << super << "kind #{@kind.to_s.inspect} is invalid"
    end

  end

  # This is raised when an inflection token used in a pattern does not match
  # an assumed kind determined by reading previous tokens from that pattern
  # or by the given strict kind of a named pattern.
  class MisplacedInflectionToken < InflectionPatternException

    def initialize(locale, pattern, token, kind)
      super(locale, pattern, token, kind)
    end

    def message
      "" << super <<
      "token #{@token.to_s.inspect} " \
      "is not of the expected kind #{@kind.inspect}"
    end

  end

  # This is raised when a complex inflection pattern is malformed
  # and cannot be reduced to set of regular patterns.
  class ComplexPatternMalformed < InflectionPatternException

    def initialize(locale, pattern, token, complex_kind)
      unless pattern.include?(I18n::Inflector::Config::Markers::PATTERN)
        pattern = I18n::Inflector::Config::Markers::PATTERN + "#{complex_kind}{#{pattern}}"
      end
      super(locale, pattern, token, complex_kind)
    end

    def message
      "" << super << "pattern is malformed; token count differs from kind count"
    end

  end

  # This is raised when an inflection token of the same name is already defined in
  # inflections tree of translation data.
  class DuplicatedInflectionToken < InflectionConfigurationException

    attr_accessor :original_kind

    def initialize(locale, token, kind, original_kind)
      super(locale, token, kind)
      @original_kind = original_kind
    end

    def message
      "" << super <<
      "token #{@token.inspect} " \
      "was already assigned to the kind #{@original_kind.inspect}"
    end

  end

  # This is raised when an alias for an inflection token points to a token that
  # doesn't exists. It is also raised when default token of some kind points
  # to a non-existent token.
  class BadInflectionAlias < InflectionConfigurationException

    attr_accessor :pointer

    def initialize(locale, token, kind, pointer)
      super(locale, token, kind)
      @pointer = pointer
    end

    def message
      what = token == :default ? "default token" : "alias #{@token.inspect}"
      "" << super <<
      "the #{what} " \
      "points to an unknown token #{@pointer.inspect}"
    end

  end

  # This is raised when an inflection token or its description has a bad name. This
  # includes an empty name or a name containing prohibited characters.
  class BadInflectionToken < InflectionConfigurationException

    attr_accessor :description

    def initialize(locale, token, kind=nil, description=nil)
      super(locale, token, kind)
      @description = description
    end

    def message
      if @description.nil?
        "" << super <<
        "inflection token #{@token.inspect} " \
        "has a bad name"
      else
        "" << super <<
        "inflection token #{@token.inspect} " \
        "has a bad description #{@description.inspect}"
      end
    end

  end


  # This is raised when an inflection kind has a bad name
  # or is not a root for a tree of tokens.
  class BadInflectionKind < InflectionConfigurationException

    def initialize(locale, kind)
      super(locale, nil, kind)
    end

    def message
        "" << super <<
        "inflection kind #{@kind.inspect} has bad name or type"
    end

  end

end

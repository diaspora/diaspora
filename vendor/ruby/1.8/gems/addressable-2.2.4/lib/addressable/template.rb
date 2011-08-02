# encoding:utf-8
#--
# Addressable, Copyright (c) 2006-2010 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "addressable/version"
require "addressable/uri"

module Addressable
  ##
  # This is an implementation of a URI template based on
  # <a href="http://tinyurl.com/uritemplatedraft03">URI Template draft 03</a>.
  class Template
    # Constants used throughout the template code.
    anything =
      Addressable::URI::CharacterClasses::RESERVED +
      Addressable::URI::CharacterClasses::UNRESERVED
    OPERATOR_EXPANSION =
      /\{-([a-zA-Z]+)\|([#{anything}]+)\|([#{anything}]+)\}/
    VARIABLE_EXPANSION = /\{([#{anything}]+?)(?:=([#{anything}]+))?\}/

    ##
    # Raised if an invalid template value is supplied.
    class InvalidTemplateValueError < StandardError
    end

    ##
    # Raised if an invalid template operator is used in a pattern.
    class InvalidTemplateOperatorError < StandardError
    end

    ##
    # Raised if an invalid template operator is used in a pattern.
    class TemplateOperatorAbortedError < StandardError
    end

    ##
    # This class represents the data that is extracted when a Template
    # is matched against a URI.
    class MatchData
      ##
      # Creates a new MatchData object.
      # MatchData objects should never be instantiated directly.
      #
      # @param [Addressable::URI] uri
      #   The URI that the template was matched against.
      def initialize(uri, template, mapping) # :nodoc:
        @uri = uri.dup.freeze
        @template = template
        @mapping = mapping.dup.freeze
      end

      ##
      # @return [Addressable::URI]
      #   The URI that the Template was matched against.
      attr_reader :uri

      ##
      # @return [Addressable::Template]
      #   The Template used for the match.
      attr_reader :template

      ##
      # @return [Hash]
      #   The mapping that resulted from the match.
      #   Note that this mapping does not include keys or values for
      #   variables that appear in the Template, but are not present
      #   in the URI.
      attr_reader :mapping

      ##
      # @return [Array]
      #   The list of variables that were present in the Template.
      #   Note that this list will include variables which do not appear
      #   in the mapping because they were not present in URI.
      def variables
        self.template.variables
      end
      alias_method :keys, :variables

      ##
      # @return [Array]
      #   The list of values that were captured by the Template.
      #   Note that this list will include nils for any variables which
      #   were in the Template, but did not appear in the URI.
      def values
        @values ||= self.variables.inject([]) do |accu, key|
          accu << self.mapping[key]
          accu
        end
      end
      alias_method :captures, :values

      ##
      # Returns a <tt>String</tt> representation of the MatchData's state.
      #
      # @return [String] The MatchData's state, as a <tt>String</tt>.
      def inspect
        sprintf("#<%s:%#0x RESULT:%s>",
          self.class.to_s, self.object_id, self.mapping.inspect)
      end
    end

    ##
    # Creates a new <tt>Addressable::Template</tt> object.
    #
    # @param [#to_str] pattern The URI Template pattern.
    #
    # @return [Addressable::Template] The initialized Template object.
    def initialize(pattern)
      if !pattern.respond_to?(:to_str)
        raise TypeError, "Can't convert #{pattern.class} into String."
      end
      @pattern = pattern.to_str.freeze
    end

    ##
    # @return [String] The Template object's pattern.
    attr_reader :pattern

    ##
    # Returns a <tt>String</tt> representation of the Template object's state.
    #
    # @return [String] The Template object's state, as a <tt>String</tt>.
    def inspect
      sprintf("#<%s:%#0x PATTERN:%s>",
        self.class.to_s, self.object_id, self.pattern)
    end

    ##
    # Extracts a mapping from the URI using a URI Template pattern.
    #
    # @param [Addressable::URI, #to_str] uri
    #   The URI to extract from.
    #
    # @param [#restore, #match] processor
    #   A template processor object may optionally be supplied.
    #
    # The object should respond to either the <tt>restore</tt> or
    # <tt>match</tt> messages or both.  The <tt>restore</tt> method should take
    # two parameters: [String] name and [String] value.  The <tt>restore</tt>
    # method should reverse any transformations that have been performed on the
    # value to ensure a valid URI.  The <tt>match</tt> method should take a
    # single parameter: [String] name.  The <tt>match</tt> method should return
    # a <tt>String</tt> containing a regular expression capture group for
    # matching on that particular variable.  The default value is ".*?".  The
    # <tt>match</tt> method has no effect on multivariate operator expansions.
    #
    # @return [Hash, NilClass]
    # The <tt>Hash</tt> mapping that was extracted from the URI, or
    # <tt>nil</tt> if the URI didn't match the template.
    #
    # @example
    #   class ExampleProcessor
    #     def self.restore(name, value)
    #       return value.gsub(/\+/, " ") if name == "query"
    #       return value
    #     end
    #
    #     def self.match(name)
    #       return ".*?" if name == "first"
    #       return ".*"
    #     end
    #   end
    #
    #   uri = Addressable::URI.parse(
    #     "http://example.com/search/an+example+search+query/"
    #   )
    #   Addressable::Template.new(
    #     "http://example.com/search/{query}/"
    #   ).extract(uri, ExampleProcessor)
    #   #=> {"query" => "an example search query"}
    #
    #   uri = Addressable::URI.parse("http://example.com/a/b/c/")
    #   Addressable::Template.new(
    #     "http://example.com/{first}/{second}/"
    #   ).extract(uri, ExampleProcessor)
    #   #=> {"first" => "a", "second" => "b/c"}
    #
    #   uri = Addressable::URI.parse("http://example.com/a/b/c/")
    #   Addressable::Template.new(
    #     "http://example.com/{first}/{-list|/|second}/"
    #   ).extract(uri)
    #   #=> {"first" => "a", "second" => ["b", "c"]}
    def extract(uri, processor=nil)
      match_data = self.match(uri, processor)
      return (match_data ? match_data.mapping : nil)
    end

    ##
    # Extracts match data from the URI using a URI Template pattern.
    #
    # @param [Addressable::URI, #to_str] uri
    #   The URI to extract from.
    #
    # @param [#restore, #match] processor
    #   A template processor object may optionally be supplied.
    #
    # The object should respond to either the <tt>restore</tt> or
    # <tt>match</tt> messages or both. The <tt>restore</tt> method should take
    # two parameters: [String] name and [String] value. The <tt>restore</tt>
    # method should reverse any transformations that have been performed on the
    # value to ensure a valid URI. The <tt>match</tt> method should take a
    # single parameter: [String] name. The <tt>match</tt> method should return
    # a <tt>String</tt> containing a regular expression capture group for
    # matching on that particular variable. The default value is ".*?". The
    # <tt>match</tt> method has no effect on multivariate operator expansions.
    #
    # @return [Hash, NilClass]
    # The <tt>Hash</tt> mapping that was extracted from the URI, or
    # <tt>nil</tt> if the URI didn't match the template.
    #
    # @example
    #   class ExampleProcessor
    #     def self.restore(name, value)
    #       return value.gsub(/\+/, " ") if name == "query"
    #       return value
    #     end
    #
    #     def self.match(name)
    #       return ".*?" if name == "first"
    #       return ".*"
    #     end
    #   end
    #
    #   uri = Addressable::URI.parse(
    #     "http://example.com/search/an+example+search+query/"
    #   )
    #   match = Addressable::Template.new(
    #     "http://example.com/search/{query}/"
    #   ).match(uri, ExampleProcessor)
    #   match.variables
    #   #=> ["query"]
    #   match.captures
    #   #=> ["an example search query"]
    #
    #   uri = Addressable::URI.parse("http://example.com/a/b/c/")
    #   match = Addressable::Template.new(
    #     "http://example.com/{first}/{second}/"
    #   ).match(uri, ExampleProcessor)
    #   match.variables
    #   #=> ["first", "second"]
    #   match.captures
    #   #=> ["a", "b/c"]
    #
    #   uri = Addressable::URI.parse("http://example.com/a/b/c/")
    #   match = Addressable::Template.new(
    #     "http://example.com/{first}/{-list|/|second}/"
    #   ).match(uri)
    #   match.variables
    #   #=> ["first", "second"]
    #   match.captures
    #   #=> ["a", ["b", "c"]]
    def match(uri, processor=nil)
      uri = Addressable::URI.parse(uri)
      mapping = {}

      # First, we need to process the pattern, and extract the values.
      expansions, expansion_regexp =
        parse_template_pattern(pattern, processor)
      unparsed_values = uri.to_str.scan(expansion_regexp).flatten

      if uri.to_str == pattern
        return Addressable::Template::MatchData.new(uri, self, mapping)
      elsif expansions.size > 0 && expansions.size == unparsed_values.size
        expansions.each_with_index do |expansion, index|
          unparsed_value = unparsed_values[index]
          if expansion =~ OPERATOR_EXPANSION
            operator, argument, variables =
              parse_template_expansion(expansion)
            extract_method = "extract_#{operator}_operator"
            if ([extract_method, extract_method.to_sym] &
                private_methods).empty?
              raise InvalidTemplateOperatorError,
                "Invalid template operator: #{operator}"
            else
              begin
                send(
                  extract_method.to_sym, unparsed_value, processor,
                  argument, variables, mapping
                )
              rescue TemplateOperatorAbortedError
                return nil
              end
            end
          else
            name = expansion[VARIABLE_EXPANSION, 1]
            value = unparsed_value
            if processor != nil && processor.respond_to?(:restore)
              value = processor.restore(name, value)
            end
            if mapping[name] == nil || mapping[name] == value
              mapping[name] = value
            else
              return nil
            end
          end
        end
        return Addressable::Template::MatchData.new(uri, self, mapping)
      else
        return nil
      end
    end

    ##
    # Expands a URI template into another URI template.
    #
    # @param [Hash] mapping The mapping that corresponds to the pattern.
    # @param [#validate, #transform] processor
    #   An optional processor object may be supplied. 
    #
    # The object should respond to either the <tt>validate</tt> or
    # <tt>transform</tt> messages or both. Both the <tt>validate</tt> and
    # <tt>transform</tt> methods should take two parameters: <tt>name</tt> and
    # <tt>value</tt>. The <tt>validate</tt> method should return <tt>true</tt>
    # or <tt>false</tt>; <tt>true</tt> if the value of the variable is valid,
    # <tt>false</tt> otherwise. An <tt>InvalidTemplateValueError</tt>
    # exception will be raised if the value is invalid. The <tt>transform</tt>
    # method should return the transformed variable value as a <tt>String</tt>.
    # If a <tt>transform</tt> method is used, the value will not be percent
    # encoded automatically. Unicode normalization will be performed both
    # before and after sending the value to the transform method.
    #
    # @return [Addressable::Template] The partially expanded URI template.
    #
    # @example
    #   Addressable::Template.new(
    #     "http://example.com/{one}/{two}/"
    #   ).partial_expand({"one" => "1"}).pattern
    #   #=> "http://example.com/1/{two}/"
    #
    #   Addressable::Template.new(
    #     "http://example.com/search/{-list|+|query}/"
    #   ).partial_expand(
    #     {"query" => "an example search query".split(" ")}
    #   ).pattern
    #   #=> "http://example.com/search/an+example+search+query/"
    #
    #   Addressable::Template.new(
    #     "http://example.com/{-join|&|one,two}/"
    #   ).partial_expand({"one" => "1"}).pattern
    #   #=> "http://example.com/?one=1{-prefix|&two=|two}"
    #
    #   Addressable::Template.new(
    #     "http://example.com/{-join|&|one,two,three}/"
    #   ).partial_expand({"one" => "1", "three" => 3}).pattern
    #   #=> "http://example.com/?one=1{-prefix|&two=|two}&three=3"
    def partial_expand(mapping, processor=nil)
      result = self.pattern.dup
      transformed_mapping = transform_mapping(mapping, processor)
      result.gsub!(
        /#{OPERATOR_EXPANSION}|#{VARIABLE_EXPANSION}/
      ) do |capture|
        if capture =~ OPERATOR_EXPANSION
          operator, argument, variables, default_mapping =
            parse_template_expansion(capture, transformed_mapping)
          expand_method = "expand_#{operator}_operator"
          if ([expand_method, expand_method.to_sym] & private_methods).empty?
            raise InvalidTemplateOperatorError,
              "Invalid template operator: #{operator}"
          else
            send(
              expand_method.to_sym, argument, variables,
              default_mapping, true
            )
          end
        else
          varname, _, vardefault = capture.scan(/^\{(.+?)(=(.*))?\}$/)[0]
          if transformed_mapping[varname]
            transformed_mapping[varname]
          elsif vardefault
            "{#{varname}=#{vardefault}}"
          else
            "{#{varname}}"
          end
        end
      end
      return Addressable::Template.new(result)
    end

    ##
    # Expands a URI template into a full URI.
    #
    # @param [Hash] mapping The mapping that corresponds to the pattern.
    # @param [#validate, #transform] processor
    #   An optional processor object may be supplied.
    #
    # The object should respond to either the <tt>validate</tt> or
    # <tt>transform</tt> messages or both. Both the <tt>validate</tt> and
    # <tt>transform</tt> methods should take two parameters: <tt>name</tt> and
    # <tt>value</tt>. The <tt>validate</tt> method should return <tt>true</tt>
    # or <tt>false</tt>; <tt>true</tt> if the value of the variable is valid,
    # <tt>false</tt> otherwise. An <tt>InvalidTemplateValueError</tt>
    # exception will be raised if the value is invalid. The <tt>transform</tt>
    # method should return the transformed variable value as a <tt>String</tt>.
    # If a <tt>transform</tt> method is used, the value will not be percent
    # encoded automatically. Unicode normalization will be performed both
    # before and after sending the value to the transform method.
    #
    # @return [Addressable::URI] The expanded URI template.
    #
    # @example
    #   class ExampleProcessor
    #     def self.validate(name, value)
    #       return !!(value =~ /^[\w ]+$/) if name == "query"
    #       return true
    #     end
    #
    #     def self.transform(name, value)
    #       return value.gsub(/ /, "+") if name == "query"
    #       return value
    #     end
    #   end
    #
    #   Addressable::Template.new(
    #     "http://example.com/search/{query}/"
    #   ).expand(
    #     {"query" => "an example search query"},
    #     ExampleProcessor
    #   ).to_str
    #   #=> "http://example.com/search/an+example+search+query/"
    #
    #   Addressable::Template.new(
    #     "http://example.com/search/{-list|+|query}/"
    #   ).expand(
    #     {"query" => "an example search query".split(" ")}
    #   ).to_str
    #   #=> "http://example.com/search/an+example+search+query/"
    #
    #   Addressable::Template.new(
    #     "http://example.com/search/{query}/"
    #   ).expand(
    #     {"query" => "bogus!"},
    #     ExampleProcessor
    #   ).to_str
    #   #=> Addressable::Template::InvalidTemplateValueError
    def expand(mapping, processor=nil)
      result = self.pattern.dup
      transformed_mapping = transform_mapping(mapping, processor)
      result.gsub!(
        /#{OPERATOR_EXPANSION}|#{VARIABLE_EXPANSION}/
      ) do |capture|
        if capture =~ OPERATOR_EXPANSION
          operator, argument, variables, default_mapping =
            parse_template_expansion(capture, transformed_mapping)
          expand_method = "expand_#{operator}_operator"
          if ([expand_method, expand_method.to_sym] & private_methods).empty?
            raise InvalidTemplateOperatorError,
              "Invalid template operator: #{operator}"
          else
            send(expand_method.to_sym, argument, variables, default_mapping)
          end
        else
          varname, _, vardefault = capture.scan(/^\{(.+?)(=(.*))?\}$/)[0]
          transformed_mapping[varname] || vardefault
        end
      end
      return Addressable::URI.parse(result)
    end

    ##
    # Returns an Array of variables used within the template pattern.
    # The variables are listed in the Array in the order they appear within
    # the pattern.  Multiple occurrences of a variable within a pattern are
    # not represented in this Array.
    #
    # @return [Array] The variables present in the template's pattern.
    def variables
      @variables ||= ordered_variable_defaults.map { |var, val| var }.uniq
    end
    alias_method :keys, :variables

    ##
    # Returns a mapping of variables to their default values specified
    # in the template. Variables without defaults are not returned.
    #
    # @return [Hash] Mapping of template variables to their defaults
    def variable_defaults
      @variable_defaults ||=
        Hash[*ordered_variable_defaults.reject { |k, v| v.nil? }.flatten]
    end

  private
    def ordered_variable_defaults
      @ordered_variable_defaults ||= (begin
        expansions, expansion_regexp = parse_template_pattern(pattern)

        expansions.inject([]) do |result, expansion|
          case expansion
          when OPERATOR_EXPANSION
            _, _, variables, mapping = parse_template_expansion(expansion)
            result.concat variables.map { |var| [var, mapping[var]] }
          when VARIABLE_EXPANSION
            result << [$1, $2]
          end
          result
        end
      end)
    end

    ##
    # Transforms a mapping so that values can be substituted into the
    # template.
    #
    # @param [Hash] mapping The mapping of variables to values.
    # @param [#validate, #transform] processor
    #   An optional processor object may be supplied.
    #
    # The object should respond to either the <tt>validate</tt> or
    # <tt>transform</tt> messages or both. Both the <tt>validate</tt> and
    # <tt>transform</tt> methods should take two parameters: <tt>name</tt> and
    # <tt>value</tt>. The <tt>validate</tt> method should return <tt>true</tt>
    # or <tt>false</tt>; <tt>true</tt> if the value of the variable is valid,
    # <tt>false</tt> otherwise. An <tt>InvalidTemplateValueError</tt> exception
    # will be raised if the value is invalid. The <tt>transform</tt> method
    # should return the transformed variable value as a <tt>String</tt>. If a
    # <tt>transform</tt> method is used, the value will not be percent encoded
    # automatically. Unicode normalization will be performed both before and
    # after sending the value to the transform method.
    #
    # @return [Hash] The transformed mapping.
    def transform_mapping(mapping, processor=nil)
      return mapping.inject({}) do |accu, pair|
        name, value = pair
        value = value.to_s if Numeric === value || Symbol === value

        unless value.respond_to?(:to_ary) || value.respond_to?(:to_str)
          raise TypeError,
            "Can't convert #{value.class} into String or Array."
        end

        if Symbol === name
          name = name.to_s
        elsif name.respond_to?(:to_str)
          name = name.to_str
        else
          raise TypeError,
            "Can't convert #{name.class} into String."
        end
        value = value.respond_to?(:to_ary) ? value.to_ary : value.to_str

        # Handle unicode normalization
        if value.kind_of?(Array)
          value.map! { |val| Addressable::IDNA.unicode_normalize_kc(val) }
        else
          value = Addressable::IDNA.unicode_normalize_kc(value)
        end

        if processor == nil || !processor.respond_to?(:transform)
          # Handle percent escaping
          if value.kind_of?(Array)
            transformed_value = value.map do |val|
              Addressable::URI.encode_component(
                val, Addressable::URI::CharacterClasses::UNRESERVED)
            end
          else
            transformed_value = Addressable::URI.encode_component(
              value, Addressable::URI::CharacterClasses::UNRESERVED)
          end
        end

        # Process, if we've got a processor
        if processor != nil
          if processor.respond_to?(:validate)
            if !processor.validate(name, value)
              display_value = value.kind_of?(Array) ? value.inspect : value
              raise InvalidTemplateValueError,
                "#{name}=#{display_value} is an invalid template value."
            end
          end
          if processor.respond_to?(:transform)
            transformed_value = processor.transform(name, value)
            if transformed_value.kind_of?(Array)
              transformed_value.map! do |val|
                Addressable::IDNA.unicode_normalize_kc(val)
              end
            else
              transformed_value =
                Addressable::IDNA.unicode_normalize_kc(transformed_value)
            end
          end
        end

        accu[name] = transformed_value
        accu
      end
    end

    ##
    # Expands a URI Template opt operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_opt_operator(argument, variables, mapping, partial=false)
      variables_present = variables.any? do |variable|
        mapping[variable] != [] &&
        mapping[variable]
      end
      if partial && !variables_present
        "{-opt|#{argument}|#{variables.join(",")}}"
      elsif variables_present
        argument
      else
        ""
      end
    end

    ##
    # Expands a URI Template neg operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_neg_operator(argument, variables, mapping, partial=false)
      variables_present = variables.any? do |variable|
        mapping[variable] != [] &&
        mapping[variable]
      end
      if partial && !variables_present
        "{-neg|#{argument}|#{variables.join(",")}}"
      elsif variables_present
        ""
      else
        argument
      end
    end

    ##
    # Expands a URI Template prefix operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_prefix_operator(argument, variables, mapping, partial=false)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'prefix' takes exactly one variable."
      end
      value = mapping[variables.first]
      if !partial || value
        if value.kind_of?(Array)
          (value.map { |list_value| argument + list_value }).join("")
        elsif value
          argument + value.to_s
        end
      else
        "{-prefix|#{argument}|#{variables.first}}"
      end
    end

    ##
    # Expands a URI Template suffix operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_suffix_operator(argument, variables, mapping, partial=false)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'suffix' takes exactly one variable."
      end
      value = mapping[variables.first]
      if !partial || value
        if value.kind_of?(Array)
          (value.map { |list_value| list_value + argument }).join("")
        elsif value
          value.to_s + argument
        end
      else
        "{-suffix|#{argument}|#{variables.first}}"
      end
    end

    ##
    # Expands a URI Template join operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_join_operator(argument, variables, mapping, partial=false)
      if !partial
        variable_values = variables.inject([]) do |accu, variable|
          if !mapping[variable].kind_of?(Array)
            if mapping[variable]
              accu << variable + "=" + (mapping[variable])
            end
          else
            raise InvalidTemplateOperatorError,
              "Template operator 'join' does not accept Array values."
          end
          accu
        end
        variable_values.join(argument)
      else
        buffer = ""
        state = :suffix
        variables.each_with_index do |variable, index|
          if !mapping[variable].kind_of?(Array)
            if mapping[variable]
              if buffer.empty? || buffer[-1..-1] == "}"
                buffer << (variable + "=" + (mapping[variable]))
              elsif state == :suffix
                buffer << argument
                buffer << (variable + "=" + (mapping[variable]))
              else
                buffer << (variable + "=" + (mapping[variable]))
              end
            else
              if !buffer.empty? && (buffer[-1..-1] != "}" || state == :prefix)
                buffer << "{-opt|#{argument}|#{variable}}"
                state = :prefix
              end
              if buffer.empty? && variables.size == 1
                # Evaluates back to itself
                buffer << "{-join|#{argument}|#{variable}}"
              else
                buffer << "{-prefix|#{variable}=|#{variable}}"
              end
              if (index != (variables.size - 1) && state == :suffix)
                buffer << "{-opt|#{argument}|#{variable}}"
              elsif index != (variables.size - 1) &&
                  mapping[variables[index + 1]]
                buffer << argument
                state = :prefix
              end
            end
          else
            raise InvalidTemplateOperatorError,
              "Template operator 'join' does not accept Array values."
          end
        end
        buffer
      end
    end

    ##
    # Expands a URI Template list operator.
    #
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The expanded result.
    def expand_list_operator(argument, variables, mapping, partial=false)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'list' takes exactly one variable."
      end
      if !partial || mapping[variables.first]
        values = mapping[variables.first]
        if values
          if values.kind_of?(Array)
            values.join(argument)
          else
            raise InvalidTemplateOperatorError,
              "Template operator 'list' only accepts Array values."
          end
        end
      else
        "{-list|#{argument}|#{variables.first}}"
      end
    end

    ##
    # Parses a URI template expansion <tt>String</tt>.
    #
    # @param [String] expansion The operator <tt>String</tt>.
    # @param [Hash] mapping An optional mapping to merge defaults into.
    #
    # @return [Array]
    #   A tuple of the operator, argument, variables, and mapping.
    def parse_template_expansion(capture, mapping={})
      operator, argument, variables = capture[1...-1].split("|", -1)
      operator.gsub!(/^\-/, "")
      variables = variables.split(",", -1)
      mapping = (variables.inject({}) do |accu, var|
        varname, _, vardefault = var.scan(/^(.+?)(=(.*))?$/)[0]
        accu[varname] = vardefault
        accu
      end).merge(mapping)
      variables = variables.map { |var| var.gsub(/=.*$/, "") }
      return operator, argument, variables, mapping
    end

    ##
    # Generates the <tt>Regexp</tt> that parses a template pattern.
    #
    # @param [String] pattern The URI template pattern.
    # @param [#match] processor The template processor to use.
    #
    # @return [Regexp]
    #   A regular expression which may be used to parse a template pattern.
    def parse_template_pattern(pattern, processor=nil)
      # Escape the pattern. The two gsubs restore the escaped curly braces
      # back to their original form. Basically, escape everything that isn't
      # within an expansion.
      escaped_pattern = Regexp.escape(
        pattern
      ).gsub(/\\\{(.*?)\\\}/) do |escaped|
        escaped.gsub(/\\(.)/, "\\1")
      end

      expansions = []

      # Create a regular expression that captures the values of the
      # variables in the URI.
      regexp_string = escaped_pattern.gsub(
        /#{OPERATOR_EXPANSION}|#{VARIABLE_EXPANSION}/
      ) do |expansion|
        expansions << expansion
        if expansion =~ OPERATOR_EXPANSION
          capture_group = "(.*)"
          operator, argument, names, _ =
            parse_template_expansion(expansion)
          if processor != nil && processor.respond_to?(:match)
            # We can only lookup the match values for single variable
            # operator expansions. Besides, ".*" is usually the only
            # reasonable value for multivariate operators anyways.
            if ["prefix", "suffix", "list"].include?(operator)
              capture_group = "(#{processor.match(names.first)})"
            end
          elsif operator == "prefix"
            capture_group = "(#{Regexp.escape(argument)}.*?)"
          elsif operator == "suffix"
            capture_group = "(.*?#{Regexp.escape(argument)})"
          end
          capture_group
        else
          capture_group = "(.*?)"
          if processor != nil && processor.respond_to?(:match)
            name = expansion[/\{([^\}=]+)(=[^\}]+)?\}/, 1]
            capture_group = "(#{processor.match(name)})"
          end
          capture_group
        end
      end

      # Ensure that the regular expression matches the whole URI.
      regexp_string = "^#{regexp_string}$"

      return expansions, Regexp.new(regexp_string)
    end

    ##
    # Extracts a URI Template opt operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_opt_operator(
        value, processor, argument, variables, mapping)
      if value != "" && value != argument
        raise TemplateOperatorAbortedError,
          "Value for template operator 'opt' was unexpected."
      end
    end

    ##
    # Extracts a URI Template neg operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_neg_operator(
        value, processor, argument, variables, mapping)
      if value != "" && value != argument
        raise TemplateOperatorAbortedError,
          "Value for template operator 'neg' was unexpected."
      end
    end

    ##
    # Extracts a URI Template prefix operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_prefix_operator(
        value, processor, argument, variables, mapping)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'prefix' takes exactly one variable."
      end
      if value[0...argument.size] != argument
        raise TemplateOperatorAbortedError,
          "Value for template operator 'prefix' missing expected prefix."
      end
      values = value.split(argument, -1)
      values << "" if value[-argument.size..-1] == argument
      values.shift if values[0] == ""
      values.pop if values[-1] == ""

      if processor && processor.respond_to?(:restore)
        values.map! { |value| processor.restore(variables.first, value) }
      end
      values = values.first if values.size == 1
      if mapping[variables.first] == nil || mapping[variables.first] == values
        mapping[variables.first] = values
      else
        raise TemplateOperatorAbortedError,
          "Value mismatch for repeated variable."
      end
    end

    ##
    # Extracts a URI Template suffix operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_suffix_operator(
        value, processor, argument, variables, mapping)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'suffix' takes exactly one variable."
      end
      if value[-argument.size..-1] != argument
        raise TemplateOperatorAbortedError,
          "Value for template operator 'suffix' missing expected suffix."
      end
      values = value.split(argument, -1)
      values.pop if values[-1] == ""
      if processor && processor.respond_to?(:restore)
        values.map! { |value| processor.restore(variables.first, value) }
      end
      values = values.first if values.size == 1
      if mapping[variables.first] == nil || mapping[variables.first] == values
        mapping[variables.first] = values
      else
        raise TemplateOperatorAbortedError,
          "Value mismatch for repeated variable."
      end
    end

    ##
    # Extracts a URI Template join operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_join_operator(value, processor, argument, variables, mapping)
      unparsed_values = value.split(argument)
      parsed_variables = []
      for unparsed_value in unparsed_values
        name = unparsed_value[/^(.+?)=(.+)$/, 1]
        parsed_variables << name
        parsed_value = unparsed_value[/^(.+?)=(.+)$/, 2]
        if processor && processor.respond_to?(:restore)
          parsed_value = processor.restore(name, parsed_value)
        end
        if mapping[name] == nil || mapping[name] == parsed_value
          mapping[name] = parsed_value
        else
          raise TemplateOperatorAbortedError,
            "Value mismatch for repeated variable."
        end
      end
      for variable in variables
        if !parsed_variables.include?(variable) && mapping[variable] != nil
          raise TemplateOperatorAbortedError,
            "Value mismatch for repeated variable."
        end
      end
      if (parsed_variables & variables) != parsed_variables
        raise TemplateOperatorAbortedError,
          "Template operator 'join' variable mismatch: " +
          "#{parsed_variables.inspect}, #{variables.inspect}"
      end
    end

    ##
    # Extracts a URI Template list operator.
    #
    # @param [String] value The unparsed value to extract from.
    # @param [#restore] processor The processor object.
    # @param [String] argument The argument to the operator.
    # @param [Array] variables The variables the operator is working on.
    # @param [Hash] mapping The mapping of variables to values.
    #
    # @return [String] The extracted result.
    def extract_list_operator(value, processor, argument, variables, mapping)
      if variables.size != 1
        raise InvalidTemplateOperatorError,
          "Template operator 'list' takes exactly one variable."
      end
      values = value.split(argument, -1)
      values.pop if values[-1] == ""
      if processor && processor.respond_to?(:restore)
        values.map! { |value| processor.restore(variables.first, value) }
      end
      if mapping[variables.first] == nil || mapping[variables.first] == values
        mapping[variables.first] = values
      else
        raise TemplateOperatorAbortedError,
          "Value mismatch for repeated variable."
      end
    end
  end
end

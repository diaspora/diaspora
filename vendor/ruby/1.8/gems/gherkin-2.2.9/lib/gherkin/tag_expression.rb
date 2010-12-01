require 'gherkin/native'

module Gherkin
  class TagExpression
    native_impl('gherkin')

    attr_reader :limits

    def initialize(tag_expressions)
      @ands = []
      @limits = {}
      tag_expressions.each do |expr|
        add(expr.strip.split(/\s*,\s*/))
      end
    end

    def empty?
      @ands.empty?
    end

    def eval(tags)
      return true if @ands.flatten.empty?
      vars = Hash[*tags.map{|tag| [tag, true]}.flatten]
      !!Kernel.eval(ruby_expression)
    end

  private

    def add(tags_with_negation_and_limits)
      negatives, positives = tags_with_negation_and_limits.partition{|tag| tag =~ /^~/}
      @ands << (store_and_extract_limits(negatives, true) + store_and_extract_limits(positives, false))
    end

    def store_and_extract_limits(tags_with_negation_and_limits, negated)
      tags_with_negation = []
      tags_with_negation_and_limits.each do |tag_with_negation_and_limit|
        tag_with_negation, limit = tag_with_negation_and_limit.split(':')
        tags_with_negation << tag_with_negation
        if limit
          tag_without_negation = negated ? tag_with_negation[1..-1] : tag_with_negation
          if @limits[tag_without_negation] && @limits[tag_without_negation] != limit.to_i
            raise "Inconsistent tag limits for #{tag_without_negation}: #{@limits[tag_without_negation]} and #{limit.to_i}" 
          end
          @limits[tag_without_negation] = limit.to_i
        end
      end
      tags_with_negation
    end

    def ruby_expression
      "(" + @ands.map do |ors|
        ors.map do |tag|
          if tag =~ /^~(.*)/
            "!vars['#{$1}']"
          else
            "vars['#{tag}']"
          end
        end.join("||")
      end.join(")&&(") + ")"
    end
  end
end

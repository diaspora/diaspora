require 'json'
require 'gherkin/formatter/model'
require 'gherkin/native'

module Gherkin
  class JSONParser
    native_impl('gherkin')

    def initialize(formatter)
      @formatter = formatter
    end

    # Parse a gherkin object +o+, which can either be a JSON String,
    # or a Hash (from a parsed JSON String).
    def parse(o, feature_uri='unknown.json', line_offset=0)
      o = JSON.parse(o) if String === o
      @formatter.uri(feature_uri)

      Formatter::Model::Feature.new(comments(o), tags(o), keyword(o), name(o), description(o), line(o)).replay(@formatter)
      (o["elements"] || []).each do |feature_element|
        feature_element(feature_element).replay(@formatter)
        (feature_element["steps"] || []).each do |step|
          step(step).replay(@formatter)
        end
        (feature_element["examples"] || []).each do |eo|
          Formatter::Model::Examples.new(comments(eo), tags(eo), keyword(eo), name(eo), description(eo), line(eo), rows(eo['rows'])).replay(@formatter)
        end
      end

      @formatter.eof
    end

    def feature_element(o)
      case o['type']
      when 'background'
        Formatter::Model::Background.new(comments(o), keyword(o), name(o), description(o), line(o))
      when 'scenario'
        Formatter::Model::Scenario.new(comments(o), tags(o), keyword(o), name(o), description(o), line(o))
      when 'scenario_outline'
        Formatter::Model::ScenarioOutline.new(comments(o), tags(o), keyword(o), name(o), description(o), line(o))
      end
    end

    def step(o)
      multiline_arg = nil
      if(ma = o['multiline_arg'])
        if(ma['type'] == 'table')
          multiline_arg = rows(ma['value'])
        else
          multiline_arg = Formatter::Model::PyString.new(ma['value'], ma['line'])
        end
      end
      Formatter::Model::Step.new(comments(o), keyword(o), name(o), line(o), multiline_arg)
    end

    def rows(o)
      o.map{|row| Formatter::Model::Row.new(comments(row), row['cells'], row['line'])}
    end

    def comments(o)
      (o['comments'] || []).map do |comment|
        Formatter::Model::Comment.new(comment['value'], comment['line'])
      end
    end

    def tags(o)
      (o['tags'] || []).map do |tag|
        Formatter::Model::Tag.new(tag['name'], tag['line'])
      end
    end

    def keyword(o)
      o['keyword']
    end

    def name(o)
      o['name']
    end

    def description(o)
      o['description']
    end

    def line(o)
      o['line']
    end
  end
end

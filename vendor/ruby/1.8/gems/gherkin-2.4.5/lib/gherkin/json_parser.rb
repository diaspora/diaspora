require 'json'
require 'gherkin/formatter/model'
require 'gherkin/formatter/argument'
require 'gherkin/native'
require 'base64'

module Gherkin
  class JSONParser
    native_impl('gherkin')

    include Base64

    def initialize(reporter, formatter)
      @reporter, @formatter = reporter, formatter
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
          match(step)
          result(step)
          embeddings(step)
        end
        (feature_element["examples"] || []).each do |eo|
          Formatter::Model::Examples.new(comments(eo), tags(eo), keyword(eo), name(eo), description(eo), line(eo), rows(eo['rows'])).replay(@formatter)
        end
      end

      @formatter.eof
    end

  private

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
      step = Formatter::Model::Step.new(comments(o), keyword(o), name(o), line(o))

      if(ma = o['multiline_arg'])
        if(ma['type'] == 'table')
          step.multiline_arg = rows(ma['value'])
        else
          step.multiline_arg = Formatter::Model::DocString.new(ma['value'], ma['line'])
        end
      end

      step
    end

    def match(o)
      if(m = o['match'])
        Formatter::Model::Match.new(arguments(m), location(m)).replay(@reporter)
      end
    end

    def result(o)
      if(r = o['result'])
        Formatter::Model::Result.new(status(r), duration(r), error_message(r)).replay(@reporter)
      end
    end

    def embeddings(o)
      (o['embeddings'] || []).each do |embedding|
        @reporter.embedding(embedding['mime_type'], Base64::decode64(embedding['data']))
      end
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

    def arguments(m)
      m['arguments'].map{|a| Formatter::Argument.new(a['offset'], a['val'])}
    end

    def location(m)
      m['location']
    end

    def status(r)
      r['status']
    end

    def duration(r)
      r['duration']
    end

    def error_message(r)
      r['error_message']
    end
  end
end

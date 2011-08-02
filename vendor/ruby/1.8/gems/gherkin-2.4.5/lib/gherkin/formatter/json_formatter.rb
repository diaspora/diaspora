require 'json'
require 'gherkin/formatter/model'
require 'gherkin/native'
require 'base64'

module Gherkin
  module Formatter
    class JSONFormatter
      native_impl('gherkin')
      
      include Base64
      attr_reader :gherkin_object
      
      # Creates a new instance that writes the resulting JSON to +io+.
      # If +io+ is nil, the JSON will not be written, but instead a Ruby
      # object can be retrieved with #gherkin_object
      def initialize(io)
        @io = io
      end

      def uri(uri)
        # We're ignoring the uri - we don't want it as part of the JSON
        # (The pretty formatter uses it just for visual niceness - comments)
      end

      def feature(feature)
        @gherkin_object = feature.to_hash
      end

      def background(background)
        feature_elements << background.to_hash
      end

      def scenario(scenario)
        feature_elements << scenario.to_hash
      end

      def scenario_outline(scenario_outline)
        feature_elements << scenario_outline.to_hash
      end

      def examples(examples)
        all_examples << examples.to_hash
      end

      def step(step)
        current_steps << step.to_hash
      end

      def match(match)
        last_step['match'] = match.to_hash
      end

      def result(result)
        last_step['result'] = result.to_hash
      end

      def embedding(mime_type, data)
        embeddings << {'mime_type' => mime_type, 'data' => encode64s(data)}
      end

      def eof
        @io.write(@gherkin_object.to_json) if @io
      end

    private

      def feature_elements
        @gherkin_object['elements'] ||= []
      end

      def feature_element
        feature_elements[-1]
      end

      def all_examples
        feature_element['examples'] ||= []
      end

      def current_steps
        feature_element['steps'] ||= []
      end

      def last_step
        current_steps[-1]
      end

      def embeddings
        last_step['embeddings'] ||= []
      end

      def encode64s(data)
        # Strip newlines
        Base64.encode64(data).gsub(/\n/, '')
      end
    end
  end
end


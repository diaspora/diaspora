require "json"
require "cucumber/formatter/io"

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json
      class Error < StandardError
      end

      include Io

      def initialize(step_mother, io, options)
        @io      = ensure_io(io, "json")
        @options = options
      end

      def before_features(features)
        @json = {:features => []}
      end

      def before_feature(feature)
        @current_object = {:file => feature.file, :name => feature.name}
        @json[:features] << @current_object
      end

      def before_tags(tags)
        @current_object[:tags] = tags.tag_names.to_a
      end

      def before_background(background)
        background = {}
        @current_object[:background] = background
        @current_object = background
      end

      def after_background(background)
        @current_object = last_feature
      end

      def before_feature_element(feature_element)
        elements = @current_object[:elements] ||= []

        # change current object to the feature_element
        @current_object = {}
        elements << @current_object
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @current_object[:keyword] = keyword
        @current_object[:name] = name
        @current_object[:file_colon_line] = file_colon_line
      end

      def before_steps(steps)
        @current_object[:steps] = []
      end

      def before_step(step)
        @current_step = {}
        @current_object[:steps] << @current_step
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if exception
          @current_step[:exception] = exception_hash_for(exception)
        end
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @current_step[:status]          = status
        @current_step[:keyword]         = keyword
        @current_step[:name]            = "#{step_match.name || step_match.format_args}"
        @current_step[:file_colon_line] = step_match.file_colon_line
      end

      def after_step(step)
        @current_step = nil
      end

      def before_examples(examples)
        @current_object[:examples] = {}
      end

      def examples_name(keyword, name)
        @current_object[:examples][:name] = "#{keyword} #{name}"
      end

      def before_outline_table(*args)
        @current_object[:examples][:table] = []
      end

      def before_table_row(row)
        @current_row = {:cells => []}

        if @current_object.member? :examples
          @current_object[:examples][:table] << @current_row
        elsif @current_step
          (@current_step[:table] ||= []) << @current_row
        else
          internal_error
        end
      end

      def table_cell_value(value, status)
        @current_row[:cells] << {:text => value, :status => status}
      end

      def after_table_row(row)
        if row.exception
          @current_row[:exception] = exception_hash_for(row.exception)
        end
        @current_row = nil
      end

      def py_string(string)
        @current_step[:py_string] = string
      end

      def after_feature_element(feature_element)
        # change current object back to the last feature
        @current_object = last_feature
      end

      def after_features(features)
        @io.write json_string
        @io.flush
      end

      def embed(file, mime_type)
        obj = @current_step || @current_object
        obj[:embedded] ||= []

        obj[:embedded] << {
          :file      => file,
          :mime_type => mime_type,
          :data      => [File.read(file)].pack("m*") # base64
        }
      end

      private

      def json_string
        @json.to_json
      end

      def last_feature
        @json[:features].last
      end

      def exception_hash_for(e)
        {
          :class     => e.class.name,
          :message   => e.message,
          :backtrace => e.backtrace
        }
      end

      def internal_error
        raise Error, "you've found a bug in the JSON formatter!"
      end

    end # Json
  end # Formatter
end # Cucumber


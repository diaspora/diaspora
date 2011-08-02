require 'new_relic/metric_parser'
module NewRelic
  module MetricParser
    class View < NewRelic::MetricParser::MetricParser
      def is_view?; true; end

      def is_render?
        segments.last == "Rendering"
      end
      def is_compiler?
        segments.last == "Compile"
      end
      def pie_chart_label
        case segments.last
        when "Rendering"
          "#{file_name(segments[-2])} Template"
        when "Partial"
          "#{file_name(segments[-2])} Partial"
        when ".rhtml Processing"
          "ERB compilation"
        else
          segments[1..-1]
        end
      end
      def template_label
        case segments.last
        when "Rendering"
          "#{file_name(segments[1..-2].join(NewRelic::MetricParser::MetricParser::SEPARATOR))} Template"
        when "Partial"
          "#{file_name(segments[1..-2].join(NewRelic::MetricParser::MetricParser::SEPARATOR))} Partial"
        when ".rhtml Processing"
          "ERB compilation"
        else
          segments[1..-1].join("/")
        end
      end

      def short_name
        segments[1..-2].join(NewRelic::MetricParser::MetricParser::SEPARATOR)
      end

      def controller_name
        template_label
      end

      def action_name
        # Strip the extension
        segments[-2].gsub(/\..*$/, "")
      end

      def developer_name
        template_label
      end

      def url
        '/' + file_name(segments[1..-2].join('/'))
      end
      private
      def file_name(path)
        label = path.gsub /\.html\.rhtml/, '.rhtml'
        label = segments[1] if label.empty?
        label
      end
    end
  end
end

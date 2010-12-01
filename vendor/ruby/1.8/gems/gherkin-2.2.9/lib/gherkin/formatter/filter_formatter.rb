require 'gherkin/tag_expression'
require 'gherkin/formatter/regexp_filter'
require 'gherkin/formatter/line_filter'
require 'gherkin/formatter/tag_filter'
require 'gherkin/formatter/model'
require 'gherkin/native'

module Gherkin
  module Formatter
    class FilterFormatter
      native_impl('gherkin')
      
      def initialize(formatter, filters)
        @formatter = formatter
        @filter    = detect_filter(filters)

        @feature_tags           = []
        @feature_element_tags   = []
        @examples_tags          = []

        @feature_events         = []
        @background_events      = []
        @feature_element_events = []
        @examples_events        = []
      end

      def uri(uri)
        @formatter.uri(uri)
      end

      def feature(feature)
        @feature_tags   = feature.tags
        @feature_name   = feature.name
        @feature_events = [feature]
      end

      def background(background)
        @feature_element_name   = background.name
        @feature_element_range  = background.line_range
        @background_events      = [background]
      end

      def scenario(scenario)
        replay!
        @feature_element_tags   = scenario.tags
        @feature_element_name   = scenario.name
        @feature_element_range  = scenario.line_range
        @feature_element_events = [scenario]
      end

      def scenario_outline(scenario_outline)
        replay!
        @feature_element_tags   = scenario_outline.tags
        @feature_element_name   = scenario_outline.name
        @feature_element_range  = scenario_outline.line_range
        @feature_element_events = [scenario_outline]
      end

      def examples(examples)
        replay!
        @examples_tags = examples.tags
        @examples_name = examples.name

        table_body_range = examples.rows[1].line..examples.rows[-1].line
        @examples_range = examples.line_range.first..table_body_range.last
        if(@filter.eval([], [], [table_body_range]))
          examples.rows = @filter.filter_table_body_rows(examples.rows)
        end
        @examples_events = [examples]
      end

      def step(step)
        if @feature_element_events.any?
          @feature_element_events << step
        else
          @background_events << step
        end

        @feature_element_range = @feature_element_range.first..step.line_range.last
      end

      def eof
        replay!
        @formatter.eof
      end

    private

      def detect_filter(filters)
        raise "Inconsistent filters: #{filters.inspect}" if filters.map{|filter| filter.class}.uniq.length > 1
        case(filters[0])
        when Fixnum 
          LineFilter.new(filters)
        when Regexp 
          RegexpFilter.new(filters)
        when String 
          TagFilter.new(filters)
        end
      end

      def replay!
        feature_element_ok = @filter.eval(
          (@feature_tags + @feature_element_tags), 
          [@feature_name, @feature_element_name].compact, 
          [@feature_element_range].compact
        )
        examples_ok = @filter.eval(
          (@feature_tags + @feature_element_tags + @examples_tags), 
          [@feature_name, @feature_element_name, @examples_name].compact, 
          [@feature_element_range, @examples_range].compact
        )

        if feature_element_ok || examples_ok
          replay_events!(@feature_events)
          replay_events!(@background_events)
          replay_events!(@feature_element_events)

          if examples_ok
            replay_events!(@examples_events)
          end
        end

        @examples_events.clear
        @examples_tags.clear
        @examples_name = nil
      end

      def replay_events!(events)
        events.each do |event|
          event.replay(@formatter)
        end
        events.clear
      end
    end
  end
end

require 'gherkin/native'
require 'gherkin/formatter/model'

module Gherkin
  module Listener
    # Adapter from the "raw" Gherkin <tt>Listener</tt> API
    # to the slightly more high-level <tt>Formatter</tt> API,
    # which is easier to implement (less state to keep track of).
    class FormatterListener
      native_impl('gherkin')

      def initialize(formatter)
        @formatter = formatter
        @comments = []
        @tags = []
        @table = nil
      end

      def comment(value, line)
        @comments << Formatter::Model::Comment.new(value, line)
      end

      def tag(name, line)
        @tags << Formatter::Model::Tag.new(name, line)
      end

      def feature(keyword, name, description, line)
        @formatter.feature(Formatter::Model::Feature.new(grab_comments!, grab_tags!, keyword, name, description, line))
      end

      def background(keyword, name, description, line)
        @formatter.background(Formatter::Model::Background.new(grab_comments!, keyword, name, description, line))
      end

      def scenario(keyword, name, description, line)
        replay_step_or_examples
        @formatter.scenario(Formatter::Model::Scenario.new(grab_comments!, grab_tags!, keyword, name, description, line))
      end

      def scenario_outline(keyword, name, description, line)
        replay_step_or_examples
        @formatter.scenario_outline(Formatter::Model::ScenarioOutline.new(grab_comments!, grab_tags!, keyword, name, description, line))
      end

      def examples(keyword, name, description, line)
        replay_step_or_examples
        @examples_statement = Formatter::Model::Examples.new(grab_comments!, grab_tags!, keyword, name, description, line)
      end

      def step(keyword, name, line)
        replay_step_or_examples
        @step_statement = Formatter::Model::Step.new(grab_comments!, keyword, name, line)
      end

      def row(cells, line)
        @table ||= []
        @table << Formatter::Model::Row.new(grab_comments!, cells, line)
      end

      def py_string(string, line)
        @py_string = Formatter::Model::PyString.new(string, line)
      end

      def eof
        replay_step_or_examples
        @formatter.eof
      end

      def syntax_error(state, ev, legal_events, uri, line)
        @formatter.syntax_error(state, ev, legal_events, uri, line)
      end

    private

      def grab_comments!
        comments = @comments
        @comments = []
        comments
      end

      def grab_tags!
        tags = @tags
        @tags = []
        tags
      end

      def grab_rows!
        table = @table
        @table = nil
        table
      end

      def grab_py_string!
        py_string = @py_string
        @py_string = nil
        py_string
      end

      def replay_step_or_examples
        if(@step_statement)
          @step_statement.multiline_arg = grab_py_string! || grab_rows!
          @formatter.step(@step_statement)
          @step_statement = nil
        end
        if(@examples_statement)
          @examples_statement.rows = grab_rows!
          @formatter.examples(@examples_statement)
          @examples_statement = nil
        end
      end
    end
  end
end

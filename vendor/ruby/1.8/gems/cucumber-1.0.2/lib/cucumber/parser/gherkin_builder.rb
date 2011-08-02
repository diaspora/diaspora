require 'cucumber/ast'
require 'gherkin/rubify'

module Cucumber
  module Parser
    # This class conforms to the Gherkin event API and builds the
    # "legacy" AST. It will be replaced later when we have a new "clean"
    # AST.
    class GherkinBuilder
      include Gherkin::Rubify

      def ast
        @feature || @multiline_arg
      end

      def feature(feature)
        @feature = Ast::Feature.new(
          nil, 
          Ast::Comment.new(feature.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, feature.tags.map{|tag| tag.name}),
          feature.keyword,
          feature.name.lstrip,
          feature.description.rstrip,
          []
        )
        @feature.gherkin_statement(feature)
        @feature
      end

      def background(background)
        @background = Ast::Background.new(
          Ast::Comment.new(background.comments.map{|comment| comment.value}.join("\n")), 
          background.line, 
          background.keyword, 
          background.name, 
          background.description,
          steps=[]
        )
        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
        @background.gherkin_statement(background)
      end

      def scenario(statement)
        scenario = Ast::Scenario.new(
          @background, 
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, statement.tags.map{|tag| tag.name}), 
          statement.line, 
          statement.keyword, 
          statement.name,
          statement.description, 
          steps=[]
        )
        @feature.add_feature_element(scenario)
        @background.feature_elements << scenario if @background
        @step_container = scenario
        scenario.gherkin_statement(statement)
      end

      def scenario_outline(statement)
        scenario_outline = Ast::ScenarioOutline.new(
          @background, 
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, statement.tags.map{|tag| tag.name}), 
          statement.line, 
          statement.keyword, 
          statement.name, 
          statement.description, 
          steps=[],
          example_sections=[]
        )
        @feature.add_feature_element(scenario_outline)
        if @background
          @background = @background.dup
          @background.feature_elements << scenario_outline
        end
        @step_container = scenario_outline
        scenario_outline.gherkin_statement(statement)
      end

      def examples(examples)
        examples_fields = [
          Ast::Comment.new(examples.comments.map{|comment| comment.value}.join("\n")), 
          examples.line, 
          examples.keyword, 
          examples.name, 
          examples.description, 
          matrix(examples.rows)
        ]
        @step_container.add_examples(examples_fields, examples)
      end

      def step(step)
        @table_owner = Ast::Step.new(step.line, step.keyword, step.name)
        @table_owner.gherkin_statement(step)
        multiline_arg = rubify(step.multiline_arg)
        case(multiline_arg)
        when Gherkin::Formatter::Model::DocString
          @table_owner.multiline_arg = Ast::DocString.new(multiline_arg.value)
        when Array
          @table_owner.multiline_arg = Ast::Table.new(matrix(multiline_arg))
        end
        @step_container.add_step(@table_owner)
      end

      def eof
      end

      def syntax_error(state, event, legal_events, line)
        # raise "SYNTAX ERROR"
      end
      
    private
    
      def matrix(gherkin_table)
        gherkin_table.map do |gherkin_row|
          row = gherkin_row.cells
          class << row
            attr_accessor :line
          end
          row.line = gherkin_row.line
          row
        end
      end
    end
  end
end

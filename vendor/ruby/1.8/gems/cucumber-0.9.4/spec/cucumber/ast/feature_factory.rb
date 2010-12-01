require 'cucumber/ast'
require 'cucumber/step_mother'

module Cucumber
  module Ast
    module FeatureFactory
      class MyWorld
        def flunk
          raise "I flunked"
        end
      end
      
      def create_feature(dsl)
        dsl.Given /^a (.*) step with an inline arg:$/ do |what, table|
        end
        dsl.Given /^a (.*) step$/ do |what|
          flunk if what == 'failing'
        end
        dsl.World do
          MyWorld.new
        end

        table = Ast::Table.new([
          %w{1 22 333},
          %w{4444 55555 666666}
        ])
        py_string = Ast::PyString.new(%{\n I like\nCucumber sandwich\n})
        
        background = Ast::Background.new(Ast::Comment.new(""), 2, "Background:", "",
          [
            Step.new(3, "Given", "a passing step")
          ]
        )
        
        f = Ast::Feature.new(
          background,
          Ast::Comment.new("# My feature comment\n"),
          Ast::Tags.new(6, ['one', 'two']),
          "Feature",
          "Pretty printing",
          [Ast::Scenario.new(
            background,
            Ast::Comment.new("    # My scenario comment  \n# On two lines \n"),
            Ast::Tags.new(8, ['three', 'four']),
            9,
            "Scenario:", "A Scenario",
            [
              Step.new(10, "Given", "a passing step with an inline arg:", table),
              Step.new(11, "Given", "a happy step with an inline arg:", py_string),
              Step.new(12, "Given", "a failing step")
            ]
          )]
        )
        f.file = 'features/pretty_printing.feature'
        f.features = Features.new
        f
      end
    end
  end
end
# encoding: utf-8
require 'spec_helper'
require 'gherkin/formatter/pretty_formatter'
require 'gherkin/formatter/argument'
require 'gherkin/formatter/model'
require 'gherkin/listener/formatter_listener'
require 'gherkin/parser/parser'
require 'stringio'

module Gherkin
  module Formatter
    describe PrettyFormatter do
      include AnsiEscapes

      def assert_io(s)
        actual = @io.string
        actual.gsub!(/\e\[m/, "\e[0m") # JANSI resets without the 0.
        actual.should == s
      end
      
      def assert_pretty(input, expected_output=input)
        [true, false].each do |force_ruby|
          io = StringIO.new
          pf = Gherkin::Formatter::PrettyFormatter.new(io, true, false)
          parser = Gherkin::Parser::Parser.new(pf, true, "root", force_ruby)
          parser.parse(input, "test.feature", 0)
          output = io.string
          output.should == expected_output
        end
      end

      before do
        @io = StringIO.new
        @f = Gherkin::Formatter::PrettyFormatter.new(@io, false, true)
      end

      it "should print comments when scenario is longer" do
        @f.uri("features/foo.feature")
        @f.feature(Model::Feature.new([], [], "Feature", "Hello", "World", 1))

        @f.scenario(Model::Scenario.new([], [], "Scenario", "The scenario", "", 4))
        @f.step(Model::Step.new([], "Given ", "some stuff", 5))
        @f.step(Model::Step.new([], "When ", "foo", 6))

        @f.match(Model::Match.new([], "features/step_definitions/bar.rb:56"))
        @f.result(Model::Result.new('passed', 22, nil))

        @f.match(Model::Match.new([], "features/step_definitions/bar.rb:96"))
        @f.result(Model::Result.new('passed', 33, nil))

        assert_io(%{Feature: Hello
  World

  Scenario: The scenario #{comments}# features/foo.feature:4#{reset}
    #{executing}Given #{reset}#{executing}some stuff#{reset}     #{comments}# features/step_definitions/bar.rb:56#{reset}
#{up(1)}    #{passed}Given #{reset}#{passed}some stuff#{reset}     #{comments}# features/step_definitions/bar.rb:56#{reset}
    #{executing}When #{reset}#{executing}foo#{reset}             #{comments}# features/step_definitions/bar.rb:96#{reset}
#{up(1)}    #{passed}When #{reset}#{passed}foo#{reset}             #{comments}# features/step_definitions/bar.rb:96#{reset}
})
      end

      it "should print comments when step is longer" do
        @f.uri("features/foo.feature")
        @f.feature(Model::Feature.new([], [], "Feature", "Hello", "World", 1))
        step = Model::Step.new([], "Given ", "some stuff that is longer", 5)
        match = Model::Match.new([], "features/step_definitions/bar.rb:56")
        result = Model::Result.new('passed', 0, nil)

        @f.scenario(Model::Scenario.new([], [], "Scenario", "The scenario", "", 4))
        @f.step(step)
        @f.match(match)
        @f.result(result)

        assert_io(%{Feature: Hello
  World

  Scenario: The scenario            #{comments}# features/foo.feature:4#{reset}
    #{executing}Given #{reset}#{executing}some stuff that is longer#{reset} #{comments}# features/step_definitions/bar.rb:56#{reset}
#{up(1)}    #{passed}Given #{reset}#{passed}some stuff that is longer#{reset} #{comments}# features/step_definitions/bar.rb:56#{reset}
})
      end

      it "should highlight arguments for regular steps" do
        @f.uri("foo.feature")
        @f.scenario(Model::Scenario.new([], [], "Scenario", "Lots of cukes", "", 3))
        @f.step(Model::Step.new([], "Given ", "I have 999 cukes in my belly", 3))
        @f.match(Model::Match.new([Gherkin::Formatter::Argument.new(7, '999')], nil))
        @f.result(Model::Result.new('passed', 6, nil))

        assert_io(
          "\n" +
          "  Scenario: Lots of cukes              \e[90m# foo.feature:3\e[0m\n" +
          "    #{executing}Given #{reset}#{executing}I have #{reset}#{executing_arg}999#{reset}#{executing} cukes in my belly#{reset}\n" +
          "#{up(1)}    #{passed}Given #{reset}#{passed}I have #{reset}#{passed_arg}999#{reset}#{passed} cukes in my belly#{reset}\n"
        )
      end

      it "should prettify scenario" do
        assert_pretty(%{Feature: Feature Description
  Some preamble

  Scenario: Scenario Description
    description has multiple lines

    Given there is a step
      """
      with
        pystrings
      """
    And there is another step
      | æ   | \\|o |
      | \\|a | ø\\\\ |
    Then we will see steps
})
      end


      it "should prettify scenario outline with table" do
        assert_pretty(%{# A feature comment
@foo
Feature: Feature Description
  Some preamble
  on several
  lines

  # A Scenario Outline comment
  @bar
  Scenario Outline: Scenario Ouline Description
    Given there is a
      """
      string with <foo>
      """
    And a table with
      | <bar> |
      | <baz> |

    @zap @boing
    Examples: Examples Description
      | foo    | bar  | baz         |
      | Banana | I    | am hungry   |
      | Beer   | You  | are thirsty |
      | Bed    | They | are tired   |
})
      end

      it "should preserve tabs" do
        assert_pretty(IO.read(File.dirname(__FILE__) + '/tabs.feature'), IO.read(File.dirname(__FILE__) + '/spaces.feature'))
      end

      it "should escape backslashes and pipes" do
        io = StringIO.new
        f = Gherkin::Formatter::PrettyFormatter.new(io, true, false)
        f.__send__(:table, [Gherkin::Formatter::Model::Row.new([], ['|', '\\'], nil)])
        io.string.should == '      | \\| | \\\\ |' + "\n"
      end
    end
  end
end

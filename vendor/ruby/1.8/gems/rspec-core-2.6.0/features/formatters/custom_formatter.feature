Feature: custom formatters

  RSpec ships with general purpose output formatters. You can tell RSpec which
  one to use using the [`--format` command line
  option]('../command_line/format_option').
  
  When RSpec's built-in output formatters don't, however, give you everything
  you need, you can write your own custom formatter and tell RSpec to use that
  one instead.  The simplest way is to subclass RSpec's `BaseTextFormatter`,
  and then override just the methods that you want to modify.

  Scenario: custom formatter
    Given a file named "custom_formatter.rb" with:
      """
      require "rspec/core/formatters/base_text_formatter"

      class CustomFormatter < RSpec::Core::Formatters::BaseTextFormatter
        def initialize(output)
          super(output)
        end

        def example_started(proxy)
          output << "example: " << proxy.description
        end
      end
      """
    And a file named "example_spec.rb" with:
      """
      describe "my group" do
        specify "my example" do
        end
      end
      """
    When I run `rspec example_spec.rb --require ./custom_formatter.rb --format CustomFormatter`
    Then the output should contain "example: my example"
    And  the exit status should be 0

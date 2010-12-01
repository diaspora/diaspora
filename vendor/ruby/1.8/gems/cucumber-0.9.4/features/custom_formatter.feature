Feature: Custom Formatter

  Scenario: count tags
    When I run cucumber --format Cucumber::Formatter::TagCloud features
    Then STDERR should be empty
    Then it should fail with
      """
      | @after_file | @background_tagged_before_on_outline | @four | @lots | @one | @sample_four | @sample_one | @sample_three | @sample_two | @three | @two |
      | 1           | 1                                    | 1     | 1     | 1    | 2            | 1           | 2             | 1           | 2      | 1    |

      """

  Scenario: my own formatter
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        because I'm worth it
        Scenario: just print me
          Given this step works
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^this step works$/ do
      end
      """
    And a file named "features/support/ze/formator.rb" with:
      """
      module Ze
        class Formator
          def initialize(step_mother, io, options)
            @step_mother = step_mother
            @io = io
          end

          def before_feature(feature)
            @io.puts feature.short_name.upcase
          end

          def scenario_name(keyword, name, file_colon_line, source_indent)
            @io.puts "  #{name.upcase}"
          end
        end
      end
      """
    When I run cucumber features/f.feature --format Ze::Formator
    Then STDERR should be empty
    Then it should pass with
      """
      I'LL USE MY OWN
        JUST PRINT ME

      """

    Scenario: Legacy pre-0.7.0 formatter
      Given a standard Cucumber project directory structure
      And a file named "features/f.feature" with:
        """
        Feature: We like old cukes
          Scenario Outline: just print me
            Given this step works

            Examples: print me too
              |foo|
              |bar|
        """
      And a file named "features/step_definitions/steps.rb" with:
        """
        Given /^this step works$/ do
        end
        """
      And a file named "features/support/legacy/formator.rb" with:
        """
        module Legacy
          class Formator
            def initialize(step_mother, io, options)
              @io = io
            end

            def feature_name(name)
              @io.puts name
            end

            def scenario_name(keyword, name, file_colon_line, source_indent)
              @io.puts "#{keyword} #{name}"
            end

            def examples_name(keyword, name)
              @io.puts "#{keyword} #{name}"
            end
          end
        end
        """
      When I run cucumber features/f.feature --format Legacy::Formator
      Then STDERR should be
        """
        Legacy::Formator is using a deprecated formatter API. Starting with Cucumber 0.7.0 the signatures
        that have changed are:
          feature_name(keyword, name)  # Two arguments. The keyword argument will not contain a colon.
          scenario_name(keyword, name, file_colon_line, source_indent)  # The keyword argument will not contain a colon.
          examples_name(keyword, name)  # The keyword argument will not contain a colon.


        """
      Then it should pass with
        """
        Feature: We like old cukes
        Scenario Outline: just print me
        Examples: print me too

        """

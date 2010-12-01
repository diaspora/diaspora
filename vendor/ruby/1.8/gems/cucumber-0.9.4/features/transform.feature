Feature: transform
  In order to maintain modularity within step definitions
  As a step definition editor
  I want to register a regex to capture and tranform step definition arguments.

  Background:         
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /^I should transform ('\d+' to an Integer)$/ do |integer|
        integer.should be_kind_of(Integer)
      end

      Then /^I should transform ('\w+' to a Symbol)$/ do |symbol|
        symbol.should be_kind_of(Symbol)
      end

      Then /^I should transform ('\d+' to a Float)$/ do |float|
        float.should be_kind_of(Float)
      end

      Then /^I should transform ('\w+' to an Array)$/ do |array|
        array.should be_kind_of(Array)
      end

      Then /^I should transform ('\w+' to Nil)$/ do |string|
        string.should be_nil
      end

      Then /^I should not transform ('\d+') to an Integer$/ do |string|
        string.should be_kind_of(String)
      end

      Then /^I should transform ((?:nothing|'\d+') to an optional Integer)$/ do |integer|
        integer.should be_nil
      end
      """
    And a file named "features/support/env.rb" with:
      """
      Transform /^'\d+' to an Integer$/ do |step_arg|
        /'(\d+)' to an Integer/.match(step_arg).captures[0].to_i
      end

      Transform /^(?:nothing|'(\d+)') to an optional Integer$/ do |str|
        str ? str.to_i : nil
      end

      Transform /^'(\d+)' to a Float$/ do |integer_string|
        Transform("'#{integer_string}' to an Integer").to_f
      end

      Transform(/^('\w+') to Nil$/) {|str| nil }

      Transform(/^('\w+') to a Symbol$/) {|str| str.to_sym }

      module MyHelpers
        def fetch_array
          @array
        end
      end

      World(MyHelpers)

      Before do
        @array = []
      end

      Transform(/^('\w+') to an Array$/) {|str| fetch_array }
      """
      
  Scenario: run a specific scenario with a registered transform
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: transform with matches
          Then I should transform '10' to an Integer

        Scenario: transform with matches that capture
          Then I should transform 'abc' to a Symbol

        Scenario: transform with matches that reuse transforms
          Then I should transform '10' to a Float

        Scenario: transform with matches that use current world
          Then I should transform 'abc' to an Array

        Scenario: transform with matches that return nil
          Then I should transform 'nil' to Nil

        Scenario: transform without matches
          Then I should not transform '10' to an Integer

        Scenario: transform with optional arguments not given
          Then I should transform nothing to an optional Integer
      """
    When I run cucumber --backtrace -s features
    Then it should pass with
      """
      Feature: Step argument transformations
    
        Scenario: transform with matches
          Then I should transform '10' to an Integer

        Scenario: transform with matches that capture
          Then I should transform 'abc' to a Symbol

        Scenario: transform with matches that reuse transforms
          Then I should transform '10' to a Float

        Scenario: transform with matches that use current world
          Then I should transform 'abc' to an Array

        Scenario: transform with matches that return nil
          Then I should transform 'nil' to Nil

        Scenario: transform without matches
          Then I should not transform '10' to an Integer

        Scenario: transform with optional arguments not given
          Then I should transform nothing to an optional Integer

      7 scenarios (7 passed)
      7 steps (7 passed)
    
      """

  Scenario: run a table scenario with an unrelated registered transform
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            |      r |            ra |
            |      m |            ma |
            |      p |            pa |
      """
    And a file named "features/support/table.rb" with:
      """
      Transform /^table:number,number_plus_a$/ do |table|
        :not_what_you_were_expecting
      end

      Then "I should check the following table:" do |table|
        table.hashes.each do |hash|
          hash['letter_plus_a'].should == (hash['letter'] + 'a')
        end
      end
      """
    When I run cucumber -s features
    Then it should pass with
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            | r      | ra            |
            | m      | ma            |
            | p      | pa            |

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: run a table scenario with an related registered transform not using table
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            |      r |            ra |
            |      m |            ma |
            |      p |            pa |
      """
    And a file named "features/support/table.rb" with:
      """
      Transform /^table:letter,letter_plus_a$/ do |table|
        1
      end

      Then "I should check the following table:" do |columns|
        columns.should == 1
      end
      """
    When I run cucumber -s features
    Then it should pass with
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            | r      | ra            |
            | m      | ma            |
            | p      | pa            |

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: run a table scenario with an related registered transform using table
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            |      r |            ra |
            |      m |            ma |
            |      p |            pa |
      """
    And a file named "features/support/table.rb" with:
      """
      Transform /^table:letter,letter_plus_a$/ do |table|
        table.rows.map { |row| row.join(',') }
      end

      Then "I should check the following table:" do |rows_in_table|
        rows_in_table.should == ['r,ra','m,ma','p,pa']
      end
      """
    When I run cucumber -b -s features
    Then it should pass with
      """
      Feature: Step argument transformations

        Scenario: A table
          Then I should check the following table:
            | letter | letter_plus_a |
            | r      | ra            |
            | m      | ma            |
            | p      | pa            |

      1 scenario (1 passed)
      1 step (1 passed)

      """

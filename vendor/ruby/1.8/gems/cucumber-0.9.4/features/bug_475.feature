Feature: https://rspec.lighthouseapp.com/projects/16211/tickets/475
  Scenario: error on pystring in scenario outline with pretty formatter
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: F
        Scenario Outline: S
          Given a multiline string:
             \"\"\"
             hello <who>
             \"\"\"
        Examples:
          | who   |
          | aslak |
          | david |
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /a multiline string:/ do |s| s.should =~ /hello (\w+)/
      end
      """
    When I run cucumber features/f.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: F

        Scenario Outline: S         # features/f.feature:2
          Given a multiline string: # features/step_definitions/steps.rb:1
            \"\"\"
            hello <who>
            \"\"\"

          Examples: 
            | who   |
            | aslak |
            | david |

      2 scenarios (2 passed)
      2 steps (2 passed)
      
      """

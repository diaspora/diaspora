Feature: Table mapping
  Scenario: Mapping table shouldn't change output
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: F
        Scenario: S
          Given a table:
            | who   |
            | aslak |
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/a table:/) { |table| table.map_headers!(/who/i => 'Who')
        table.map_column!('Who') { |who| "Cuke" }
        table.hashes[0]['Who'] = "Joe"
        table.hashes.should == [{"Who"=>"Joe"}]
      }
      """
    When I run cucumber features/f.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: F

        Scenario: S      # features/f.feature:2
          Given a table: # features/step_definitions/steps.rb:1
            | who   |
            | aslak |

      1 scenario (1 passed)
      1 step (1 passed)
      
      """

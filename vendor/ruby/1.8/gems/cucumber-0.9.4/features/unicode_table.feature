Feature: Unicode in tables
  In order to please the whole world,
  unicode characters in tables should be
  properly aligned
  
  Scenario: All sorts of weird stuff
    Given a standard Cucumber project directory structure
    And a file named "features/unicode.feature" with:
      """
      Feature: Featuring unicode

        Scenario: So what, whatever
          Given passing
            | Brüno | abc |
            | Bruno | æøå |
      """
    And a file named "features/env.rb" with:
      """
      $KCODE='u'
      """
    When I run cucumber -q --dry-run features/unicode.feature
    Then it should pass with
      """
      Feature: Featuring unicode

        Scenario: So what, whatever
          Given passing
            | Brüno | abc |
            | Bruno | æøå |

      1 scenario (1 undefined)
      1 step (1 undefined)

      """
    
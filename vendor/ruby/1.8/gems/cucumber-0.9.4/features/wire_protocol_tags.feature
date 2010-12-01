@wire
Feature: Wire protocol tags
  In order to use Before and After hooks in a wire server, we send tags with the 
  scenario in the begin_scenario and end_scenario messages

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/some_remote_place.wire" with:
      """
      host: localhost
      port: 54321

      """

  Scenario: Run a scenario
    Given a file named "features/wired.feature" with:
      """
        @foo @bar
        Feature: Wired
        
          @baz
          Scenario: Everybody's Wired
            Given we're all wired

      """
    And there is a wire server running on port 54321 which understands the following protocol:
      | request                                              | response                            |
      | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]] |
      | ["begin_scenario", {"tags":["bar","baz","foo"]}]     | ["success"]                         |
      | ["invoke",{"id":"1","args":[]}]                      | ["success"]                         |
      | ["end_scenario", {"tags":["bar","baz","foo"]}]       | ["success"]                         |
    When I run cucumber -f pretty -q
    Then STDERR should be empty
    And it should pass with
      """
      @foo @bar
      Feature: Wired
      
        @baz
        Scenario: Everybody's Wired
          Given we're all wired

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Run a scenario outline example
  Given a file named "features/wired.feature" with:
    """
      @foo @bar
      Feature: Wired
      
        @baz
        Scenario Outline: Everybody's Wired
          Given we're all <something>
          
        Examples:
          | something |
          | wired     |

    """
  And there is a wire server running on port 54321 which understands the following protocol:
    | request                                              | response                            |
    | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[{"id":"1", "args":[]}]] |
    | ["begin_scenario", {"tags":["bar","baz","foo"]}]     | ["success"]                         |
    | ["invoke",{"id":"1","args":[]}]                      | ["success"]                         |
    | ["end_scenario", {"tags":["bar","baz","foo"]}]       | ["success"]                         |
  When I run cucumber -f pretty -q
  Then STDERR should be empty
  And it should pass with
    """
    @foo @bar
    Feature: Wired
    
      @baz
      Scenario Outline: Everybody's Wired
        Given we're all <something>

        Examples: 
          | something |
          | wired     |

    1 scenario (1 passed)
    1 step (1 passed)

    """

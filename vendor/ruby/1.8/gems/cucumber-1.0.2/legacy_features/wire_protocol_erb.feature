@wire
Feature: Wire Protocol with ERB
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on server with multiple users
  I want to be able to configure which port my wire server runs on
  So that I can avoid port conflicts

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
      Feature: High strung
        Scenario: Wired
          Given we're all wired

      """

  Scenario: ERB is used in the wire file which references an environment variable that is not set
      Given a file named "features/step_definitions/server.wire" with:
        """
        host: localhost
        port: <%= ENV['PORT'] || 12345 %>
        """
      And there is a wire server running on port 12345 which understands the following protocol:
        | request                                              | response       |
        | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[]] |
      When I run cucumber --dry-run --no-snippets -f progress
      And it should pass with
        """
        U

        1 scenario (1 undefined)
        1 step (1 undefined)

        """


  Scenario: ERB is used in the wire file which references an environment variable
      Given I have environment variable PORT set to "16816"
      And a file named "features/step_definitions/server.wire" with:
        """
        host: localhost
        port: <%= ENV['PORT'] || 12345 %>
        """
      And there is a wire server running on port 16816 which understands the following protocol:
        | request                                              | response       |
        | ["step_matches",{"name_to_match":"we're all wired"}] | ["success",[]] |
      When I run cucumber --dry-run --no-snippets -f progress
      And it should pass with
        """
        U

        1 scenario (1 undefined)
        1 step (1 undefined)

        """


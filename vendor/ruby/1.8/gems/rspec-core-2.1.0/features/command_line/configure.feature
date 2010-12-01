Feature: configure

  Use the --configure option on the command line to generate configuration
  files.

  The only supported argument, so far, is "autotest", which creates an
  autotest/discover.rb file in your project root directory.

  Background:
    Given a directory named "rspec_project"

  Scenario: generate autotest directory and discover file
    When I cd to "rspec_project"
    And I run "rspec --configure autotest"
    Then the following directories should exist:
      | autotest |
    And the following files should exist:
      | autotest/discover.rb |
    And the file "autotest/discover.rb" should contain "Autotest.add_discovery"
    And the stdout should contain "autotest/discover.rb has been added"

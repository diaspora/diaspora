Feature: --configure option

  Use the --configure option on the command line to generate configuration
  files.

  The only supported argument, so far, is "autotest", which creates a .rspec
  file in your project root directory. When autotest sees this file, it knows
  to load RSpec's Autotest subclass.

  Scenario: generate .rspec file for autotest
    When I run `rspec --configure autotest`
    Then the following files should exist:
      | .rspec |
    And the output should contain ".rspec file did not exist, so it was created."

  Scenario: .rspec file already exists
    Given a file named ".rspec" with:
      """
      --color
      """
    When I run `rspec --configure autotest`
    Then the output should contain ".rspec file already exists, so nothing was changed."

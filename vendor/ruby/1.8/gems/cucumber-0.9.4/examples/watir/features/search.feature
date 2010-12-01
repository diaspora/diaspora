Feature: Search
  In order to learn more
  As an information seeker
  I want to find more information

  Scenario: Find what I'm looking for
    Given I am on the Google search page
    When I search for "cucumber github"
    Then I should see
      """
      GitHub
      """

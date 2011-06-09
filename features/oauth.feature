@javascript
Feature: oauth
  Exchanging oauth credentials

  Background:
    Given Chubbies has been killed
    And Chubbies is running
    And I visit "/reset" on Chubbies
    And a user with username "bob" and password "secret"

  Scenario: Authorize Chubbies
    When I try to authorize Chubbies
    Then I should see "Chubbies"
    And I should see "The best way to chub."

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

  Scenario: Not authorize Chubbies
    When I try to authorize Chubbies
    Then I should see "Chubbies"
    And I should see "The best way to chub."

    When I press "No"
    Then I should be on "/account" on Chubbies
    Then I should see "No access token."

  Scenario: Authorize Chubbies
    Given Chubbies is registered on my pod
    When I try to authorize Chubbies
    Then I should see "Chubbies"
    And I should see "The best way to chub."
    And there is only one Chubbies

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"


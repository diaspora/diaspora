@javascript
Feature: oauth
  Exchanging oauth credentials

  Background:
    Given Chubbies is running
    And a user with username "bob" and password "secret"

  Scenario: Authorize Chubbies
    When I visit "/" on Chubbies
    And I try to authorize Chubbies
    Then I should see "Authorize Chubbies?"
    And I should see "Chubbies tests Diaspora's OAuth capabilities."

    When I press "Yes"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

  Scenario: Not authorize Chubbies
    When I visit "/" on Chubbies
    And I try to authorize Chubbies
    Then I should see "Authorize Chubbies?"
    And I should see "Chubbies tests Diaspora's OAuth capabilities."

    When I press "No"
    Then I should be on "/callback" on Chubbies
    Then I should see "What is your major malfunction?"

  Scenario: Authorize Chubbies
    Given Chubbies is registered on my pod
    When I visit "/" on Chubbies
    And I try to authorize Chubbies
    Then I should see "Authorize Chubbies?"
    And I should see "Chubbies tests Diaspora's OAuth capabilities."

    When I press "Yes"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"


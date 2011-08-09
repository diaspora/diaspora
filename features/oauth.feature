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

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

  Scenario: Not authorize Chubbies
    When I try to authorize Chubbies

    When I press "No"
    Then I should be on "/account" on Chubbies
    Then I should see "No access token."

  Scenario: Authorize Chubbies when Chubbies is already connected
    Given Chubbies is registered on my pod
    When I try to authorize Chubbies
    And there is only one Chubbies

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

  Scenario: Authorize Chubbies when the pod knows about Chubbies
    Given Chubbies is registered on my pod
    When I try to authorize Chubbies
    And I visit "/reset" on Chubbies
    And I go to the destroy user session page

    When I try to authorize Chubbies
    And there is only one Chubbies

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"
  
  Scenario: Authorize Chubbies should place it on the authorized applications page
    When I try to authorize Chubbies

    When I press "Authorize"

    And I am on the authorizations page
    Then I should see "Chubbies"
    And I should see "The best way to chub."

  Scenario: Removing Chubbies from the authorized applications list de-authorizes it
    When I try to authorize Chubbies

    When I press "Authorize"

    And I am on the authorizations page
    And I preemptively confirm the alert
    And I follow "Revoke Access"
    Then I visit "/account?id=1" on Chubbies
    Then I should see "Token invalid"

  Scenario: Re-registering a client if the client recognizes the diaspora pod but the diaspora pod has since been reset
    Given Chubbies is registered on my pod
    And I remove all traces of Chubbies on the pod

    When I try to authorize Chubbies

    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

  Scenario: Login in with Chubbies when you already authorized it
    Given Chubbies is registered on my pod
    When I try to authorize Chubbies
    When I press "Authorize"
    Then I should be on "/account" on Chubbies
    And I should see my "profile.birthday"
    And I should see my "name"

    Then I visit "/new" on Chubbies
    And I fill in "Diaspora Handle" with "#{@me.diaspora_handle}"
    And I press "Connect to Diaspora"

    And I debug
    Then I should be on "/account" on Chubbies


@javascript @oauth-group
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

  Scenario: Signup+login (Diaspora Connect) with Chubbies
    When I visit "/reset" on Chubbies
    And I should have 0 user on Chubbies
    And I try to authorize Chubbies
    And I press "Authorize"
    Then I should be on "/account" on Chubbies

    And I should have 1 user on Chubbies

  Scenario: Signing up as a user while someone else is logged into Diaspora
    When I change the app_host to Diaspora
    Given a user with username "alice"
    When I sign in as "alice@alice.alice"
    Then I visit "/new" on Chubbies
    And I fill in "Diaspora ID" with "bob@localhost:9887"
    And I press "Connect to Diaspora"
    Then I should be on the new user session page
    And the "Username" field within "#user_new" should contain "bob"
  
  Scenario: Not authorize Chubbies
    When I try to authorize Chubbies

    When I press "No"
    Then I should be on "/account" on Chubbies
    And I should have 0 user on Chubbies

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
    And I change the app_host to Diaspora
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

    And I change the app_host to Diaspora
    And I am on the authorizations page
    Then I should see "Chubbies"
    And I should see "The best way to chub."

  Scenario: Removing Chubbies from the authorized applications list de-authorizes it
    When I try to authorize Chubbies

    When I press "Authorize"

    And I change the app_host to Diaspora
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
    And I should have 0 user on Chubbies

    When I try to authorize Chubbies
    When I press "Authorize"
    Then I should be on "/account" on Chubbies

    And I should have 1 user on Chubbies
    Then I visit "/new" on Chubbies
    And I fill in my Diaspora ID to connect
    And I press "Connect to Diaspora"

    Then I should be on "/account" on Chubbies
    And I should have 1 user on Chubbies
    When I change the app_host to Diaspora



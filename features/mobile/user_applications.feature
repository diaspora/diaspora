@javascript @mobile
Feature: managing authorized applications
  Background:
    Given following users exist:
      | username    | email                 |
      | Augier      | augier@example.org    |
    And a client with a provided picture exists for user "augier@example.org"
    And a client exists for user "augier@example.org"

  Scenario: displaying authorizations
    When I sign in as "augier@example.org" on the mobile website
    And I go to the user applications page
    Then I should see 2 authorized applications
    And I should see 1 authorized applications with no provided image
    And I should see 1 authorized applications with an image

  Scenario: revoke an authorization
    When I sign in as "augier@example.org" on the mobile website
    And I go to the user applications page
    And I revoke the first authorization
    Then I should see 1 authorized applications
    And I revoke the first authorization
    Then I should see 0 authorized applications

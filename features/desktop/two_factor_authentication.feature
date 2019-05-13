# frozen_string_literal: true
@javascript
Feature: Two-factor autentication

  Scenario: Activate 2fa
    Given a user with email "alice@test.com"
    When I sign in as "alice@test.com"
    When I go to the two-factor authentication page
    And I press "Activate"
    Then I should see "Confirm activation"
    When I scan the QR code and fill in a valid TOTP token for "alice@test.com"
    And I press "Confirm and activate"
    Then I should see "Two-factor authentication activated"
    And I should see "Recovery codes"
    When I confirm activation
    Then I should see "Two-factor authentication activated"
    And I should see "Deactivate"

  Scenario: Signing in with 2fa activated and correct token
    Given a user with username "alice" and password "secret"
    And 2fa is activated for "alice"
    When I go to the login page
    And I fill in username "alice" and password "secret"
    And press "Sign in"
    Then I should see "Two-factor authentication"
    When I fill in a valid TOTP token for "alice"
    And I press "Sign in"
    Then I should be on the stream page

  Scenario: Trying to sign in with 2fa activated and incorrect token
    Given a user with username "alice" and password "secret"
    And 2fa is activated for "alice"
    When I go to the login page
    And I fill in username "alice" and password "secret"
    And press "Sign in"
    Then I should see "Two-factor authentication"
    When I fill in an invalid TOTP token
    And I press "Sign in"
    Then I should see "Two-factor authentication"

  Scenario: Signing in with 2fa activated and a recovery code
    Given a user with username "alice" and password "secret"
    And 2fa is activated for "alice"
    When I go to the login page
    And I fill in username "alice" and password "secret"
    And press "Sign in"
    Then I should see "Two-factor authentication"
    When I fill in a recovery code from "alice"
    And I press "Sign in"
    Then I should be on the stream page

  Scenario: Regenerating recovery codes
    Given a user with email "alice@test.com"
    And 2fa is activated for "alice@test.com"
    When I sign in as "alice@test.com"
    When I go to the two-factor authentication page
    Then I should see "Generate new recovery codes"
    When I press the recovery code generate button
    Then I should see a list of recovery codes

  Scenario: Deactivating 2fa with correct password
    Given a user with email "alice@test.com"
    And 2fa is activated for "alice@test.com"
    When I sign in as "alice@test.com"
    When I go to the two-factor authentication page
    Then I should see "Deactivate"
    When I put in my password in "two_factor_authentication_password"
    And I press "Deactivate"
    Then I should see "Two-factor authentication not activated"

  Scenario: Trying to deactivate with incorrect password
    Given a user with email "alice@test.com"
    And 2fa is activated for "alice@test.com"
    When I sign in as "alice@test.com"
    When I go to the two-factor authentication page
    Then I should see "Deactivate"
    When I fill in "two_factor_authentication_password" with "incorrect"
    And I press "Deactivate"
    Then I should see "Two-factor authentication activated"
    And I should see "Deactivate"

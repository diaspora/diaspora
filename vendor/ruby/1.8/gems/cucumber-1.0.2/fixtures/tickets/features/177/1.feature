# Users want to know that nobody can masquerade as them.  We want to extend trust
# only to visitors who present the appropriate credentials.  Everyone wants this
# identity verification to be as secure and convenient as possible.
Feature: Logging in
  As an anonymous user with an account
  I want to log in to my account
  So that I can be myself

  #
  # Log in: get form
  #
  Scenario: Anonymous user can get a login form.
    Given I am logged out
    When  I go to "/login"
    Then  I should be at the "sessions/new" page

  #
  # Log in successfully, but don't remember me
  #
  Scenario: Anonymous user can log in
    Given an "activated" user named "reggie" exists
     And  I am logged out
    When  I go to "/login"
     And  I fill in "Login" with "reggie"
     And  I fill in "Password" with "password"
     And  I press "Log in"
    Then  I should be at the "dashboard/index" page


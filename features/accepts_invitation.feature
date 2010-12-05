@javascript
Feature: invitation acceptance
    Scenario: accept invitation
      Given I have been invited by an admin
      And I am on my acceptance form page
      And I fill in "Username" with "ohai"
      And I fill in "user_password" with "secret"
      And I fill in "Password confirmation" with "secret"
      And I press "Sign up"
      Then I should be on the getting started page
      And I should see "Welcome to Diaspora!"      
      And I should see "ohai"


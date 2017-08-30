@javascript
Feature: new user registration

  Background:
    When I go to the new user registration page
    And I fill in the new user form
    And I submit the form
    Then I should be on the getting started page
    Then I should see the 'getting started' contents

  Scenario: new user goes through the setup wizard
    When I fill in the following:
      | profile_first_name | O             |
    And I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And the publisher should be expanded
    And I close the publisher
    Then I should not see "awesome_button"
    And I should not see any posts in my stream

  Scenario: new user tries to XSS itself
    When I fill in the following:
      | profile_first_name | <script>alert(0)// |
    And I focus the "follow_tags" field
    Then I should see a flash message containing "Hey, <script>alert(0)//!"

  Scenario: new user does not add any tags in setup wizard and cancel the alert
    When I fill in the following:
      | profile_first_name | some name     |
    And I focus the "follow_tags" field
    Then I should see a flash message containing "Hey, some name!"
    When I reject the alert after I follow "awesome_button"
    Then I should be on the getting started page
    And I should see a flash message containing "All right, I’ll wait."

  Scenario: new user skips the setup wizard
    When I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And the publisher should be expanded

  Scenario: first status message is public
    When I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And the publisher should be expanded
    And I should see "Public" within ".aspect-dropdown"

  Scenario: new user without any tags posts first status message
    When I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And the publisher should be expanded
    When I wait for the popovers to appear
    And I click close on all the popovers
    And I submit the publisher
    Then "Hey everyone, I’m #newhere." should be post 1

  Scenario: new user with some tags posts first status message
    When I fill in the following:
      | profile_first_name | some name        |
    And I fill in "tags" with "#rockstar"
    And I press the first ".as-result-item" within "#as-results-tags"
    And I wait until ajax requests finished
    And I follow "awesome_button"
    Then I should be on the stream page
    And the publisher should be expanded
    When I wait for the popovers to appear
    And I click close on all the popovers
    And I submit the publisher
    Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

  Scenario: closing a popover clears getting started
    When I confirm the alert after I follow "awesome_button"
    Then I should be on the stream page
    And I wait for the popovers to appear
    And I click close on all the popovers
    And I close the publisher
    Then I should not see "Welcome to diaspora*"

  Scenario: user fills in bogus data - client side validation
    When I log out manually
    And I go to the new user registration page
    And I fill in the following:
        | user_username        | $%&(/&%$&/=)(/    |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_username, user_password, user_email"

    When I fill in the following:
        | user_username     | valid_user                        |
        | user_email        | this is not a valid email $%&/()( |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_password, user_email"

    When I fill in the following:
        | user_email        | valid@email.com        |
        | user_password     | 1                      |
    And I press "Create account"
    Then I should not be able to sign up
    And I should have a validation error on "user_password, user_password_confirmation"

  Scenario: User signs up with an already existing username and email and then tries to sign in (Issue #6136)
    When I log out manually
    And I go to the new user registration page
    And I fill in the new user form with an existing email and username
    And I submit the form
    Then I should see a flash message indicating failure
    When I click the sign in button
    Then I should not see a flash message indicating failure

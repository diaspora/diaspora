@javascript
Feature: public repost
  In order to make Diaspora more viral
  As a User
  I want to reshare my friend's post

  Background:
    Given following users exist:
      | username    | email             |
      | Bob Jones   | bob@bob.bob       |
      | Alice Smith | alice@alice.alice |
      | Eve Doe     | eve@eve.eve       |
    And a user with email "bob@bob.bob" is connected with "alice@alice.alice"
    And a user with email "eve@eve.eve" is connected with "bob@bob.bob"
    And "bob@bob.bob" has a public post with text "reshare this!"

  Scenario: Resharing a post from a single post page
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I open the show page of the "reshare this!" post
    And I click on selector "a.reshare"
    And I confirm the alert
    Then I should see a flash message indicating success
    And I should see a flash message containing "successfully"

  Scenario: Resharing a post from a single post page that is reshared
    Given the post with text "reshare this!" is reshared by "eve@eve.eve"
    And I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    And I open the show page of the "reshare this!" post
    And I click on selector "a.reshare"
    And I confirm the alert
    Then I should see a flash message indicating success
    And I should see a flash message containing "successfully"

  Scenario: Delete original reshared post
    Given "alice@alice.alice" has a public post with text "Don't reshare this!"
    And the post with text "Don't reshare this!" is reshared by "bob@bob.bob"
    And I sign in as "alice@alice.alice"
    And I am on "alice@alice.alice"'s page

    When I click to delete the first post
    And I log out
    And I sign in as "bob@bob.bob"
    Then I should see "Original post deleted by author" within ".reshare"

  # should be covered in rspec, so testing that the post is added to
  # app.stream in jasmine should be enough coverage
  Scenario: When I reshare, it shows up on my profile page
    Given I sign in as "alice@alice.alice"
    And I follow "Reshare"
    And I confirm the alert
    Then I should see a flash message indicating success
    And I should see a flash message containing "successfully"
    And I should not see a ".reshare" within ".feedback"

@javascript
Feature: Browsing Diaspora as a logged out user
    In order to view public diaspora content
    as a random internet user
    I want to view public pages

    Background:
      Given a user named "Bob Jones" with email "bob@bob.bob"
      And "bob@bob.bob" has a public post with text "public stuff"
      And I log out

    Scenario: Visiting a profile page
      When I am on "bob@bob.bob"'s page
      Then I should see "public stuff" within "body"
      And page should not have ".media .controls"

    Scenario: Visiting a post show page
      When I view "bob@bob.bob"'s first post
      Then I should see "public stuff" within "body"

    Scenario: Visiting a non-public post
      Given "bob@bob.bob" has a non public post with text "my darkest secrets"
      When I open the show page of the "my darkest secrets" post
      Then I should see the "post not public" message
      And I should not see "my darkest secrets"

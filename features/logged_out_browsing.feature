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

    Scenario: Clicking Last Post
      When I am on "bob@bob.bob"'s page
      And I follow "Last Post"
      Then I should see "public stuff" within "body"

    Scenario: Visiting a post show page
      When I view "bob@bob.bob"'s first post
      Then I should see "public stuff" within "body"

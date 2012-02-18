@javascript
Feature: Browsing Diaspora as a logged out user
    In order to view public diaspora content
    as a random internet user
    I want to view public pages

    Background:
      Given a user named "Bob Jones" with email "bob@bob.bob"
      Given "bob@bob.bob" has a public post with text "public stuff"

    Scenario: Visiting a profile page
      When I am on "bob@bob.bob"'s page
      Then I should see "public stuff"

@javascript
Feature: collapsing and expanding long posts
    In order to tame the lengths of posts in my stream
    As a rocket scientist
    I want long posts to be collapsed and expand on click

    Background:
      Given that following user exists:
        | username |
        | bob      |
      And I sign in as "bob@bob.bob"

    Scenario: post a very long message
      Given I post an extremely long status message
      And I go to the home page
      Then the post should be collapsed

    Scenario: expand a very long message
      Given I post an extremely long status message
      And I go to the home page
      And I expand the post
      Then the post should be expanded

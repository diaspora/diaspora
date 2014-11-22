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
      And I am on the home page
      And I post an extremely long status message
      And I post an extremely long status message

    Scenario: collapse an expanded post, top of post visible
      Given I go to the home page
      And I expand the post
      And I collapse the post

      Then the post should be collapsed

    Scenario: collapse an expanded post, top of post hidden
      Given I go to the home page
      And I expand the post
      And I scroll down by "300"
      And I hover over the ".stream_element"
      And I collapse the post

      Then I should have scrolled to first post
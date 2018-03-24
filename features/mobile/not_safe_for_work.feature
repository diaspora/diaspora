@javascript @mobile
Feature: Not safe for work
  Background:
    Given a nsfw user with email "tommy@nsfw.example.com"
    And a user with email "laura@office.example.com"
    And a user with email "laura@office.example.com" is connected with "tommy@nsfw.example.com"

  Scenario: Setting not safe for work
    When I sign in as "tommy@nsfw.example.com" on the mobile website
    And I go to the edit profile page
    And I mark myself as not safe for work
    And I submit the form
    Then I should be on the edit profile page
    And the "profile[nsfw]" checkbox should be checked

    When I go to the edit profile page
    And I mark myself as safe for work
    And I submit the form
    Then I should be on the edit profile page
    And the "profile[nsfw]" checkbox should not be checked

  Scenario: Toggling nsfw state
    #Nsfw users posts are marked nsfw
    Given "tommy@nsfw.example.com" has a public post with text "I love 0bj3ction4bl3 c0nt3nt!" and a poll
    And "tommy@nsfw.example.com" has a public post with text "I love 0bj3ction4bl3 c0nt3nt!" and a location
    And "tommy@nsfw.example.com" has a public post with text "I love 0bj3ction4bl3 c0nt3nt!" and a picture

    #toggling nsfw state
    When I sign in as "laura@office.example.com" on the mobile website
    Then I should not see "I love 0bj3ction4bl3 c0nt3nt!"
    And I should not see "What do you think about 1 ninjas?"
    And I should not see "Posted from:"
    And I should not see any picture in my stream

    When I toggle all nsfw posts
    Then I should see "I love 0bj3ction4bl3 c0nt3nt!"
    And I should see "What do you think about 1 ninjas?"
    And I should see "Posted from:"
    And I should see 1 pictures in my stream

  Scenario: Resharing a nsfw post with a poll
    Given "tommy@nsfw.example.com" has a public post with text "Sexy Senators Gone Wild!" and a poll

    When I sign in as "laura@office.example.com" on the mobile website
    And I toggle all nsfw posts
    And I confirm the alert after I follow "Reshare"
    Then I should see a "a.reshare-action.active"

    When I go to the home page
    Then I should not see "Sexy Senators Gone Wild!"
    And I should not see "What do you think about 1 ninjas?"
    And I should have 2 nsfw posts

  Scenario: Resharing a nsfw post with a location
    Given "tommy@nsfw.example.com" has a public post with text "Sexy Senators Gone Wild!" and a location

    When I sign in as "laura@office.example.com" on the mobile website
    And I toggle all nsfw posts
    And I confirm the alert after I follow "Reshare"
    Then I should see a "a.reshare-action.active"

    When I go to the home page
    Then I should not see "Sexy Senators Gone Wild!"
    And I should not see "Posted from:"
    And I should have 2 nsfw posts

  Scenario: Resharing a nsfw post with a picture
    Given "tommy@nsfw.example.com" has a public post with text "Sexy Senators Gone Wild!" and a picture

    When I sign in as "laura@office.example.com" on the mobile website
    And I toggle all nsfw posts
    And I confirm the alert after I follow "Reshare"
    Then I should see a "a.reshare-action.active"

    When I go to the home page
    Then I should not see "Sexy Senators Gone Wild!"
    And I should not see any picture in my stream
    And I should have 2 nsfw posts

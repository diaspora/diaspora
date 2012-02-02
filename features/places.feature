@javascript
Feature: places
  In order to let people find and talk about places
  As a Visitor or User
  I want to see what aggregated data and humanity are saying about particular places

  Background:
    Given a place called "Sally's Soups"
    Given a user with username "bob"

    When I sign in as "bob@bob.bob"
    And I see my stream
    And I click "Create a Review"
    Then I see a search field
    And I search for "Sally's Soups"
    And I press the linked title "Sally's Soups"
    And I wait for the place page for "Sally's Soups" to load  
    
  Scenario: viewing photos of the place
    Then I should see a photo of "Sally's soups" within "#places_sidebar"
    And I press the photo
    Then I should see an album of photos of "Sally's Soups"
    And I press one of the photos
    Then I should see a lightbox
    And I browse right and left
    Then I should see the entire album loaded progressively and asynchronously
    And I press ESQ or click the "x" on the lightbox
    Then I should see the album again
    And I press "Back"
    Then I should return to the place page

  Scenario: can post a review from the place page
    Then I should see "Sally's Soups" within "#publisher"
    And I post a status with the text "Would trade true love for another bowl of Sally's soup"
    And I search for "Sally's Soups"
    Then I should see "Would trade true love for another bowl of Sally's soup"

  Scenario: can post a photo from the place page
    Then I should see "Sally's Soups" within "#publisher"
    And I press the "camera" icon in "#publisher"
    Then I should see the photo upload dialog box
    And I choose two photos
    And I enter a status message with the text "I took some photos of the Leek and Chanterelle Soup"
    And I press "Share"
    And I search for "Sally's Soups"
    Then I should see "I took some photos of the Leek and Chanterelle Soup" accompanied by two photos
    
  Scenario: can mention a place from "#publisher" on any page
    Given there are two "Sally's Soups", one in Boston and one in London
    When I am viewing a tag page, a tag stream, or my home stream, mentioning a person, or anywhere else with a "#publisher"
    And I enter text "Just ate a great bowl of Leek and Chanterelle Soup at "
    And I enter text "=Sal"
    Then I should see an Auto-Complete search appear containing places that start with "Sal"
    And I enter text "=Sally's Soups"
    Then I should see "Sally's Soups - London" and "Sally's Soups - Boston"
    And I enter use my cursor to select or press "Sally's Soups - Boston"
    Then I should see "Just ate a great bowl of Leek and Chanterelle Soup at Sally's Soups" in "#publisher"
    And I press Share
    And I search for "Sally's Soups"
    Then I should see "Just ate a great bowl of Leek and Chanterelle Soup at Sally's Soups"
    And I press "Sally's Soups"
    Then I should see the place page for "Sally's Soups"

  Scenario: creating a place if there are no search results
    When I see no results for "Sally's Soups"
    And I press "Create a place page for Sally's Soups"
    Then I see a nested form for place and the place's description
    And I enter a place name, summary, location and image_url
    And I don't check "I am the owner of this place."
    And I press "Create this place"
    Then I see a place page for "Sally's Soups"

  Scenario: creating a place from "#publisher" on any page
    Given there are no places called "Sally's Soups"
    When I am viewing a tag page, a tag stream, or my home stream, mentioning a person, or anywhere else with a "#publisher"
    And I enter text "Just ate a great bowl of Leek and Chanterelle Soup at "
    And I enter text "=Sal"
    Then I should see an Auto-Complete search appear containing places that start with "Sal"
    And I enter text "=Sally's Soups"
    Then I should see no results
    And I hit enter or press "Create this place"
    Then I should see "Just ate a great bowl of Leek and Chanterelle Soup at Sally's Soups" in "#publisher"
    And I press Share
    And I search for "Sally's Soups"
    Then I should see "Just ate a great bowl of Leek and Chanterelle Soup at Sally's Soups"
    And I press "Sally's Soups"
    Then I should see the place page for "Sally's Soups"
    And I should see "Just ate a great bowl of Leek and Chanterelle Soup at Sally's Soups"

  Scenario: follow a place
    When I search for "Sally's Soups"
    And I press "Follow Sally's Soups"
    And wait for ajax to finish
    Then I should see "Following Sally's Soups"
  
  Scenario: see a place that I am following
    When I go to the home page
    And I follow "Sally's Soups"
    Then I should see "Would trade true love for another bowl of Sally's soup" within "body"

  Scenario: can stop following a place from the place page
    When I press "Following Sally's Soups"
    And I go to the followed places stream page
    Then I should not see "Sally's Soups" within ".left_nav"

  Scenario: can stop following a place from the homepage
    When I go to the followed places stream page
    And I preemptively confirm the alert
    And I hover over the "li.unfollow#place-following-sallys-soups"
    And I follow "unfollow_boss"
    And I wait for the ajax to finish
    Then I should not see "#place-following-sallys-soups" within ".left_nav"

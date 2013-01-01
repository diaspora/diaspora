@javascript
Feature: oembed
  In order to make videos easy accessible
  As a user
  I want the links in my posts be replaced by their oEmbed representation

  Background:
    Given following user exists:
      | username    | email             | 
      | Alice Smith | alice@alice.alice |
    And I have several oEmbed data in cache
    When I sign in as "alice@alice.alice"
    And I am on the home page

  Scenario: Post a secure video link
    Given I expand the publisher
    When I fill in the following:
        | status_message_fake_text    | http://youtube.com/watch?v=M3r2XDceM6A&format=json    |
    And I press "Share"
    And I wait for the ajax to finish
    And I follow "My Aspects"
    Then I should see a video player
    And I should see a ".oembed" within ".post-content"
    And I should see a "img" within ".oembed"

  Scenario: Post an unsecure video link
    Given I expand the publisher
    When I fill in the following:
        | status_message_fake_text    | http://mytube.com/watch?v=M3r2XDceM6A&format=json    |
    And I press "Share"
    And I wait for the ajax to finish
    And I follow "My Aspects"
    Then I should not see a video player
    And I should see "http://mytube.com/watch?v=M3r2XDceM6A&format=json"

  Scenario: Post an unsecure rich-typed link
    Given I expand the publisher
    When I fill in the following:
        | status_message_fake_text    | http://myrichtube.com/watch?v=M3r2XDceM6A&format=json    |
    And I press "Share"
    And I follow "My Aspects"
    Then I should not see a video player
    And I should see "http://myrichtube.com/watch?v=M3r2XDceM6A&format=json"

  Scenario: Post a photo link
    Given I expand the publisher
    When I fill in the following:
        | status_message_fake_text    | http://farm4.static.flickr.com/3123/2341623661_7c99f48bbf_m.jpg |
    And I press "Share"
    And I follow "My Aspects"
    Then I should see a "img" within ".stream_element"

  Scenario: Post an unsupported text link
    Given I expand the publisher
    When I fill in the following:
        | status_message_fake_text    | http://www.we-do-not-support-oembed.com/index.html |
    And I press "Share"
    And I follow "My Aspects"
    Then I should see "http://www.we-do-not-support-oembed.com/index.html" within ".stream_element"



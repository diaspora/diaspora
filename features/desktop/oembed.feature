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
    And I sign in as "alice@alice.alice"

  Scenario: Post a secure video link
    Given I expand the publisher
    When I click the publisher and post "http://youtube.com/watch?v=M3r2XDceM6A&format=json"
    Then I should see a video player

  Scenario: Post an unsecure video link
    Given I expand the publisher
    When I click the publisher and post "http://mytube.com/watch?v=M3r2XDceM6A&format=json"
    And I follow "My aspects"
    Then I should not see a video player
    And I should see "http://mytube.com/watch?v=M3r2XDceM6A&format=json" within ".stream-element"

  Scenario: Post an unsecure rich-typed link
    Given I expand the publisher
    When I click the publisher and post "http://myrichtube.com/watch?v=M3r2XDceM6A&format=json"
    And I follow "My aspects"
    Then I should not see a video player
    And I should see "http://myrichtube.com/watch?v=M3r2XDceM6A&format=json" within ".stream-element"

  Scenario: Post a photo link
    Given I expand the publisher
    When I click the publisher and post "http://farm4.static.flickr.com/3123/2341623661_7c99f48bbf_m.jpg"
    And I follow "My aspects"
    Then I should see a "img" within ".stream-element"

  Scenario: Post an unsupported text link
    Given I expand the publisher
    When I click the publisher and post "http://www.we-do-not-support-oembed.com/index.html"
    And I follow "My aspects"
    Then I should see "http://www.we-do-not-support-oembed.com/index.html" within ".stream-element"

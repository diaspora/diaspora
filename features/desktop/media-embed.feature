 # We can create a separate cucumber profile that will run these tests with Selenium
@nophantomjs
@javascript
Feature: oembed
  In order to make videos easy accessible
  As a user
  I want the media links in my posts be replaced by an embedded player

  Background:
    Given following user exists:
      | username    | email             |
      | Alice Smith | alice@alice.alice |
    And I sign in as "alice@alice.alice"

  Scenario: Post a video link
    When I click the publisher and post "[title](https://example.com/file.ogv)"
    Then I should see a HTML5 video player

  Scenario: Post an audio link
    When I click the publisher and post "[title](https://example.com/file.ogg)"
    Then I should see a HTML5 audio player


@localserver
Feature: Flexible uri deployment
    To make it possible to use Diaspora on small home servers,
    which might house also other sw, it should be possible to deploy
    diaspora on a sub-uri such as http://example.org/diaspora.

    Scenario: Serve webfinger request
        Given configuration parameter pod_url is http://localhost:3000/diaspora
        When I retrieve http://localhost:3000/.well-known/host-meta into tmp/host-meta
        Then I should find 'http://localhost:3000/diaspora/webfinger?q={uri}' in tmp/host-meta

    Scenario: Present application to user
        Given configuration parameter pod_url is http://localhost:3000/diaspora
        When I visit url http://localhost:3000/diaspora
        And  I retrieve http://localhost:3000/diaspora into tmp/index.html
        Then I should see "put something in"
        And  a page-asset should be http://localhost:3000/diaspora/stylesheets/ui.css
        And  I should match 'http://localhost:3000/diaspora/stylesheets/blueprint/print.css.[0-9]+"' in tmp/index.html


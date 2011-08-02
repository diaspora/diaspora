@ask
Feature: Half manual
  In order to speed up manual tests
  Testers should at least be able to automate parts of it
  
  Scenario: Check mailbox
    Given I have signed up on the web
    When I check my mailbox
    Then I should have an email containing "cukes"

  

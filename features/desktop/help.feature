@javascript
Feature: Getting help

  Scenario: Visit help page
    When I am on the help page
    Then I should see "diaspora* FAQ"
    When I follow "Mentions"
    Then I should see "What is a “mention”?" within ".faq_question_mentions .question"

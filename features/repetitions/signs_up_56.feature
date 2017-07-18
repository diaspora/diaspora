@javascript
Feature: new user registration

Background:
  When I go to the new user registration page
  And I fill in the new user form
  And I submit the form
  Then I should be on the getting started page
  Then I should see the 'getting started' contents

Scenario: 1) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 2) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 3) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 4) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 5) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 6) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 7) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 8) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 9) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 10) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 11) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 12) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 13) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 14) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 15) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 16) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 17) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 18) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 19) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 20) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 21) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 22) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 23) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 24) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 25) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 26) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 27) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 28) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 29) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

Scenario: 30) new user with some tags posts first status message
  When I fill in the following:
    | profile_first_name | some name        |
  And I fill in "tags" with "#rockstar"
  And I press the first ".as-result-item" within "#as-results-tags"
  And I follow "awesome_button"
  Then I should be on the stream page
  And the publisher should be expanded
  When I wait for the popovers to appear
  And I click close on all the popovers
  And I submit the publisher
  Then "Hey everyone, I’m #newhere. I’m interested in #rockstar." should be post 1

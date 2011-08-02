Feature: List step defs as json
  In order to build tools on top of Cucumber
  As a tool developer
  I want to be able to query a features directory for all the step definitions it contains
  
  Background: 
    Given a standard Cucumber project directory structure
  
  Scenario: Two Ruby step definitions, in the same file
    Given a file named "features/step_definitions/foo_steps.rb" with:
      """
      Given(/foo/i) {}
      Given(/b.r/xm) {}
      """
    When I run the following Ruby code:
      """
      require 'cucumber'
      puts Cucumber::StepDefinitions.new.to_json
      
      """
    Then it should pass
    And the output should contain the following JSON:
      """
      [
        {"source": "foo", "flags": "i"},
        {"source": "b.r", "flags": "mx"}
      ]
      """

  Scenario: Non-default directory structure
    Given a file named "my_weird/place/foo_steps.rb" with:
      """
      Given(/foo/) {}
      Given(/b.r/x) {}
      """
    When I run the following Ruby code:
      """
      require 'cucumber'
      puts Cucumber::StepDefinitions.new(:autoload_code_paths => ['my_weird']).to_json
      
      """
    Then it should pass
    And the output should contain the following JSON:
      """
      [
        {"source": "foo", "flags": ""},
        {"source": "b.r", "flags": "x"}
      ]
      
      """

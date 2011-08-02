Feature: Bootstrapping a new project
  In order to have the best chances of getting up and running with cucumber
  As a new cucumber user
  I want cucumber to give helpful error messages in basic situations

 Scenario: running cucumber against a non-existing feature file
  Given a directory without standard Cucumber project directory structure
    When I run `cucumber`
    Then it should fail with:
      """
      You don't have a 'features' directory.  Please create one to get started.
      See http://cukes.info/ for more information.
      """

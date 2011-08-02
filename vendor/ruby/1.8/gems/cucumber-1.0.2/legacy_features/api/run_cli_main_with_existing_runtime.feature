Feature: Run Cli::Main with existing Runtime

  This is the API that Spork uses. It creates an existing runtime then
  calls load_programming_language('rb') on it to load the RbDsl.
  When the process forks, Spork them passes the runtime to Cli::Main to 
  run it.

    Background: 
      Given a standard Cucumber project directory structure

    Scenario: Run a single feature
      Given a file named "features/step_definitions/success.rb" with:
        """
        Given(/pass/) {}
        """
      Given a file named "features/success.feature" with:
        """
        Feature: 
          Scenario: 
            Given I pass
        """
      When I run the following Ruby code:
        """
        require 'cucumber'
        runtime = Cucumber::Runtime.new
        runtime.load_programming_language('rb')
        Cucumber::Cli::Main.new([]).execute!(runtime)
        
        """
      Then it should pass
      And the output should contain:
        """
        Given I pass
        """
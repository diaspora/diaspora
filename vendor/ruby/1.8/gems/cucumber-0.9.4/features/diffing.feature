Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  @rspec2
  Scenario: Run single failing scenario with default diff enabled
    When I run cucumber -q features/failing_expectation.feature
    Then it should fail with
      """
      Feature: Failing expectation

        Scenario: Failing expectation
          Given failing expectation
            expected: "that",
                 got: "this" (using ==) (RSpec::Expectations::ExpectationNotMetError)
            ./features/step_definitions/sample_steps.rb:63:in `/^failing expectation$/'
            features/failing_expectation.feature:4:in `Given failing expectation'
      
      Failing Scenarios:
      cucumber features/failing_expectation.feature:3 # Scenario: Failing expectation
      
      1 scenario (1 failed)
      1 step (1 failed)

      """

Feature: Post Configuration Hook [#423]

  In order to extend Cucumber
  As a developer
  I want to manipulate the Cucumber configuration after it has been created

  Scenario: Using options directly gets a deprecation warning

    Given a standard Cucumber project directory structure
    And a file named "features/support/env.rb" with:
      """
      AfterConfiguration do |config|
        config.options[:blah]
      end
      """
    When I run cucumber features
    Then STDERR should match
      """
      Deprecated
      """

    Given a standard Cucumber project directory structure
    And a file named "features/support/env.rb" with:
      """
      AfterConfiguration do |config|
        config.formats << ['html', config.out_stream]
      end
      """
    When I run cucumber features
    Then STDERR should be empty
    And the output should contain
      """
      html
      """

  Scenario: feature directories read from configuration

    Given a standard Cucumber project directory structure
    And a file named "features/support/env.rb" with:
      """
      AfterConfiguration do |config|
        config.out_stream << "AfterConfiguration hook read feature directories: #{config.feature_dirs.join(', ')}" 
      end
      """
    When I run cucumber features
    Then STDERR should be empty
    And the output should contain
      """
      AfterConfiguration hook read feature directories: features
      """
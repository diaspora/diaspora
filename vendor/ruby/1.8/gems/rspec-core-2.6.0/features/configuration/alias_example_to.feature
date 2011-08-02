Feature: alias_example_to

  Use `config.alias_example_to` to create new example group methods
  that define examples with the configured metadata.

  If you set the `treat_symbols_as_metadata_keys_with_true_values` config option
  to `true`, you can specify metadata using only symbols.

  Scenario: Use alias_example_to to define focused example
    Given a file named "alias_example_to_spec.rb" with:
      """
      RSpec.configure do |c|
        c.alias_example_to :fit, :focused => true
        c.filter_run :focused => true
      end

      describe "an example group" do
        it "does one thing" do
        end

        fit "does another thing" do
        end
      end
      """
    When I run `rspec alias_example_to_spec.rb --format doc`
    Then the output should contain "does another thing"
    And the output should not contain "does one thing"

  Scenario: use symbols as metadata
    Given a file named "use_symbols_as_metadata_spec.rb" with:
      """
      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
        c.alias_example_to :fit, :focused
        c.filter_run :focused
      end

      describe "an example group" do
        it "does one thing" do
        end

        fit "does another thing" do
        end
      end
      """
    When I run `rspec use_symbols_as_metadata_spec.rb --format doc`
    Then the output should contain "does another thing"
    And the output should not contain "does one thing"

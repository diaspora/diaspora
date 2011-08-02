Feature: Define helper methods in a module

  You can define helper methods in a module and include it in
  your example groups using the `config.include` configuration
  option.  `config.extend` can be used to extend the module onto
  your example groups so that the methods in the module are available
  in the example groups themselves (but not in the actual examples).

  You can also include or extend the module onto only certain example
  groups by passing a metadata hash as the last argument.  Only groups
  that match the given metadata will include or extend the module.

  If you set the `treat_symbols_as_metadata_keys_with_true_values` config option
  to `true`, you can specify metadata using only symbols.

  Background:
    Given a file named "helpers.rb" with:
      """
      module Helpers
        def help
          :available
        end
      end
      """

  Scenario: include a module in all example groups
    Given a file named "include_module_spec.rb" with:
      """
      require './helpers'

      RSpec.configure do |c|
        c.include Helpers
      end

      describe "an example group" do
        it "has access the helper methods defined in the module" do
          help.should be(:available)
        end
      end
      """
    When I run `rspec include_module_spec.rb`
    Then the examples should all pass

  Scenario: extend a module in all example groups
    Given a file named "extend_module_spec.rb" with:
      """
      require './helpers'

      RSpec.configure do |c|
        c.extend Helpers
      end

      describe "an example group" do
        puts "Help is #{help}"

        it "does not have access to the helper methods defined in the module" do
          expect { help }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec extend_module_spec.rb`
    Then the examples should all pass
    And the output should contain "Help is available"

  Scenario: include a module in only some example groups
    Given a file named "include_module_in_some_groups_spec.rb" with:
      """
      require './helpers'

      RSpec.configure do |c|
        c.include Helpers, :foo => :bar
      end

      describe "an example group with matching metadata", :foo => :bar do
        it "has access the helper methods defined in the module" do
          help.should be(:available)
        end
      end

      describe "an example group without matching metadata" do
        it "does not have access to the helper methods defined in the module" do
          expect { help }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec include_module_in_some_groups_spec.rb`
    Then the examples should all pass

  Scenario: extend a module in only some example groups
    Given a file named "extend_module_in_only_some_groups_spec.rb" with:
      """
      require './helpers'

      RSpec.configure do |c|
        c.extend Helpers, :foo => :bar
      end

      describe "an example group with matching metadata", :foo => :bar do
        puts "In a matching group, help is #{help}"

        it "does not have access to the helper methods defined in the module" do
          expect { help }.to raise_error(NameError)
        end
      end

      describe "an example group without matching metadata" do
        puts "In a non-matching group, help is #{help rescue 'not available'}"

        it "does not have access to the helper methods defined in the module" do
          expect { help }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec extend_module_in_only_some_groups_spec.rb`
    Then the examples should all pass
    And the output should contain "In a matching group, help is available"
    And the output should contain "In a non-matching group, help is not available"

  Scenario: use symbols as metadata
    Given a file named "symbols_as_metadata_spec.rb" with:
      """
      require './helpers'

      RSpec.configure do |c|
        c.treat_symbols_as_metadata_keys_with_true_values = true
        c.include Helpers, :include_helpers
        c.extend  Helpers, :extend_helpers
      end

      describe "an example group with matching include metadata", :include_helpers do
        puts "In a group not matching the extend filter, help is #{help rescue 'not available'}"

        it "has access the helper methods defined in the module" do
          help.should be(:available)
        end
      end

      describe "an example group with matching extend metadata", :extend_helpers do
        puts "In a group matching the extend filter, help is #{help}"

        it "does not have access to the helper methods defined in the module" do
          expect { help }.to raise_error(NameError)
        end
      end
      """
    When I run `rspec symbols_as_metadata_spec.rb`
    Then the examples should all pass
    And the output should contain "In a group not matching the extend filter, help is not available"
    And the output should contain "In a group matching the extend filter, help is available"

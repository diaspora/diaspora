Feature: arbitrary helper methods

  You can define methods in any example group using Ruby's `def` keyword or
  `define_method` method. These _helper_ methods are exposed to examples in the
  group in which they are defined and groups nested within that group, but not
  parent or sibling groups.

  Scenario: use a method defined in the same group
    Given a file named "example_spec.rb" with:
      """
      describe "an example" do
        def help
          :available
        end

        it "has access to methods defined in its group" do
          help.should be(:available)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

  Scenario: use a method defined in a parent group
    Given a file named "example_spec.rb" with:
      """
      describe "an example" do
        def help
          :available
        end

        describe "in a nested group" do
          it "has access to methods defined in its parent group" do
            help.should be(:available)
          end
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

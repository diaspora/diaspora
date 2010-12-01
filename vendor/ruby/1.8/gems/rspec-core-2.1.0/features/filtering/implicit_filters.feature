Feature: implicit filters

  The `:if` and `:unless` metadata keys can be used to filter examples without
  needing to configure an exclusion filter.

  Scenario: implicit :if filter
    Given a file named "implicit_if_filter_spec.rb" with:
      """
      describe ":if => true group", :if => true do
        it(":if => true group :if => true example", :if => true) { }
        it(":if => true group :if => false example", :if => false) { }
        it(":if => true group no :if example") { }
      end

      describe ":if => false group", :if => false do
        it(":if => false group :if => true example", :if => true) { }
        it(":if => false group :if => false example", :if => false) { }
        it(":if => false group no :if example") { }
      end

      describe "no :if group" do
        it("no :if group :if => true example", :if => true) { }
        it("no :if group :if => false example", :if => false) { }
        it("no :if group no :if example") { }
      end
      """
    When I run "rspec implicit_if_filter_spec.rb --format doc"
    Then the output should contain all of these:
      | :if => true group :if => true example  |
      | :if => true group no :if example       |
      | :if => false group :if => true example |
      | no :if group :if => true example       |
      | no :if group no :if example            |
    And the output should not contain any of these:
      | :if => true group :if => false example  |
      | :if => false group :if => false example |
      | :if => false group no :if example       |
      | no :if group :if => false example       |

  Scenario: implicit :unless filter
    Given a file named "implicit_unless_filter_spec.rb" with:
      """
      describe ":unless => true group", :unless => true do
        it(":unless => true group :unless => true example", :unless => true) { }
        it(":unless => true group :unless => false example", :unless => false) { }
        it(":unless => true group no :unless example") { }
      end

      describe ":unless => false group", :unless => false do
        it(":unless => false group :unless => true example", :unless => true) { }
        it(":unless => false group :unless => false example", :unless => false) { }
        it(":unless => false group no :unless example") { }
      end

      describe "no :unless group" do
        it("no :unless group :unless => true example", :unless => true) { }
        it("no :unless group :unless => false example", :unless => false) { }
        it("no :unless group no :unless example") { }
      end
      """
    When I run "rspec implicit_unless_filter_spec.rb --format doc"
    Then the output should contain all of these:
      | :unless => true group :unless => false example  |
      | :unless => false group :unless => false example |
      | :unless => false group no :unless example       |
      | no :unless group :unless => false example       |
      | no :unless group no :unless example             |
    And the output should not contain any of these:
      | :unless => true group :unless => true example  |
      | :unless => true group no :unless example       |
      | :unless => false group :unless => true example |
      | no :unless group :unless => true example       |

  Scenario: combining implicit filter with explicit inclusion filter
    Given a file named "explicit_inclusion_filter_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run :focus => true
      end

      describe "group with :focus", :focus => true do
        it("focused example") { }
        it("focused :if => true example", :if => true) { }
        it("focused :if => false example", :if => false) { }
        it("focused :unless => true example", :unless => true) { }
        it("focused :unless => false example", :unless => false) { }
      end

      describe "group without :focus" do
        it("unfocused example") { }
        it("unfocused :if => true example", :if => true) { }
        it("unfocused :if => false example", :if => false) { }
        it("unfocused :unless => true example", :unless => true) { }
        it("unfocused :unless => false example", :unless => false) { }
      end
      """
    When I run "rspec explicit_inclusion_filter_spec.rb --format doc"
    Then the output should contain all of these:
      | focused example                  |
      | focused :if => true example      |
      | focused :unless => false example |
    And the output should not contain any of these:
      | focused :if => false example     |
      | focused :unless => true example  |
      | unfocused                        |

  Scenario: combining implicit filter with explicit exclusion filter
    Given a file named "explicit_exclusion_filter_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :broken => true
      end

      describe "unbroken group" do
        it("included example") { }
        it("included :if => true example", :if => true) { }
        it("included :if => false example", :if => false) { }
        it("included :unless => true example", :unless => true) { }
        it("included :unless => false example", :unless => false) { }
      end

      describe "broken group", :broken => true do
        it("excluded example") { }
        it("excluded :if => true example", :if => true) { }
        it("excluded :if => false example", :if => false) { }
        it("excluded :unless => true example", :unless => true) { }
        it("excluded :unless => false example", :unless => false) { }
      end
      """
    When I run "rspec explicit_exclusion_filter_spec.rb --format doc"
    Then the output should contain all of these:
      | included example                  |
      | included :if => true example      |
      | included :unless => false example |
    And the output should not contain any of these:
      | included :if => false example     |
      | included :unless => true example  |
      | excluded                          |

  Scenario: override implicit :if and :unless exclusion filters
    Given a file named "override_implicit_filters_spec.rb" with:
      """
      RSpec.configure do |c|
        c.filter_run_excluding :if => :exclude_me, :unless => :exclude_me_for_unless
      end

      describe ":if filtering" do
        it(":if => true example", :if => true) { }
        it(":if => false example", :if => false) { }
        it(":if => :exclude_me example", :if => :exclude_me) { }
      end

      describe ":unless filtering" do
        it(":unless => true example", :unless => true) { }
        it(":unless => false example", :unless => false) { }
        it(":unless => :exclude_me_for_unless example", :unless => :exclude_me_for_unless) { }
      end
      """
    When I run "rspec override_implicit_filters_spec.rb --format doc"
    Then the output should contain all of these:
      | :if => true example      |
      | :if => false example     |
      | :unless => true example  |
      | :unless => false example |
    And the output should not contain "exclude_me"


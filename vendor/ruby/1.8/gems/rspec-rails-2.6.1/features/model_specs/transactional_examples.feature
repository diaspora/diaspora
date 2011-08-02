Feature: transactional examples

  By default rspec executes each individual example in a transaction.

  You can also explicitly enable/disable transactions the configuration
  property 'use_transactional_examples'.

  Scenario: run in transactions (default)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has none after one was created in a previous example" do
          Widget.count.should == 0
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: run in transactions (explicit)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      RSpec.configure do |c|
        c.use_transactional_examples = true
      end

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has none after one was created in a previous example" do
          Widget.count.should == 0
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: disable transactions (explicit)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      RSpec.configure do |c|
        c.use_transactional_examples = false
      end

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has one after one was created in a previous example" do
          Widget.count.should == 1
        end

        after(:all) { Widget.destroy_all }
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: run in transactions with fixture
    Given a file named "spec/models/thing_spec.rb" with:
      """
      require "spec_helper"

      describe Thing do
        fixtures :things
        it "fixture method defined" do
          things(:one)
        end
      end
      """
    Given a file named "spec/fixtures/things.yml" with:
      """
      one:
        name: MyString
      """
    When I run `rspec spec/models/thing_spec.rb`
    Then the examples should all pass




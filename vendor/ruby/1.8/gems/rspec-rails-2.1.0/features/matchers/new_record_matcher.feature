Feature: be_a_new matcher

  The be_a_new matcher accepts a class and passes if the subject is an instance
  of that class that returns true to new_record?

  You can also call "with" on be_a_new with a hash of attributes to specify the
  subject has equal attributes.

  Scenario: example spec with four be_a_new possibilities 
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        context "when initialized" do
          subject { Widget.new }
          it { should be_a_new(Widget) }
          it { should_not be_a_new(String) }
        end
        context "when saved" do
          subject { Widget.create }
          it { should_not be_a_new(Widget) }
          it { should_not be_a_new(String) }
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"

  Scenario: example spec using be_a_new.with
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class Widget < ActiveRecord::Base
        establish_connection :adapter => 'sqlite3',
                             :database => ':memory:'

        connection.execute <<-eosql
          CREATE TABLE widgets (
            foo_id integer,
            number integer
          )
        eosql
      end

      describe Widget do
        context "when initialized with attributes" do
          subject { Widget.new(:foo_id => 1, :number => 1) }

          it "has all of the attributes" do
            should be_a_new(Widget).with(:foo_id => 1, :number => 1)
          end

          it "has one of the attributes" do
            should be_a_new(Widget).with(:foo_id => 1)
          end

          it "has none of the attributes" do
            should_not be_a_new(Widget).with(:blah => 'blah')
          end

          it "has one of the attribute values not the same" do
            should_not be_a_new(Widget).with(:foo_id => 2)
          end
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"

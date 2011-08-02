Feature: be_a_new matcher

  The `be_a_new` matcher accepts a class and passes if the subject is an
  instance of that class that returns false to persisted?

  You can also chain `with` on `be_a_new` with a hash of attributes to specify
  the subject has equal attributes.

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
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

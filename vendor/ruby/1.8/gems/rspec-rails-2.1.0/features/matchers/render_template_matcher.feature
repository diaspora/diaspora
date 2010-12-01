Feature: render_template matcher

  This matcher just delegates to the Rails assertion method
  "assert_template". For complete info on the available options,
  please take a look at the Rails documentation.

  This method is available in spec/controllers and spec/requests.

  Scenario: render_template with three possible options
    Given a file named "spec/controllers/gadgets_spec.rb" with:
      """
      require "spec_helper"

      describe GadgetsController do
        describe "#index" do
          subject { get :index }

          specify { should render_template(:index) }
          specify { should render_template("index") }
          specify { should render_template("gadgets/index") }
        end
      end
      """
    When I run "rspec spec/controllers/gadgets_spec.rb"
    Then the output should contain "3 examples, 0 failures"

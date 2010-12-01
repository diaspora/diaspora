Feature: controller spec readers

  Controller specs expose a number of different
  attribute readers.

  Scenario: access controller
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "is available before an action" do
          controller.should be_an_instance_of(WidgetsController)
        end
      end
      """
    When I run "rspec ./spec"
    Then the output should contain "1 example, 0 failures"

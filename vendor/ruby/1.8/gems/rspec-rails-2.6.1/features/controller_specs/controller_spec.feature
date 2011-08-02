Feature: controller spec

  Scenario: simple passing example
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        describe "GET index" do
          it "has a 200 status code" do
            get :index
            response.code.should eq("200")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

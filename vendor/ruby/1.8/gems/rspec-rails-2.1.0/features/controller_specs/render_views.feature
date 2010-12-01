Feature: render views

  You can tell a controller example group to render views with the render_views
  declaration.

  Scenario: expect template that exists and is rendered by controller (passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        render_views

        describe "index" do
          it "renders the index template" do
            get :index
            response.should contain("Listing widgets")
          end

          it "renders the widgets/index template" do
            get :index
            response.should contain("Listing widgets")
          end
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "2 examples, 0 failures"

  Scenario: expect template that does not exist and is rendered by controller (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        render_views

        before do
          def controller.index
            render :template => "other"
          end
        end

        describe "index" do
          it "renders the other template" do
            get :index
          end
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "1 example, 1 failure"
    And the output should contain "Missing template"

  Scenario: render_views on and off in diff contexts
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        context "with render_views" do
          render_views

          describe "index" do
            it "renders the actual template" do
              get :index
              response.body.should =~ /Listing widgets/m
            end
          end
        end

        context "without render_views" do
          describe "index" do
            it "renders the RSpec generated template" do
              get :index
              response.body.should == ""
            end
          end
        end

        context "with render_views again" do
          render_views

          describe "index" do
            it "renders the actual template" do
              get :index
              response.body.should =~ /Listing widgets/m
            end
          end
        end

        context "without render_views again" do
          describe "index" do
            it "renders the RSpec generated template" do
              get :index
              response.body.should == ""
            end
          end
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "4 examples, 0 failures"

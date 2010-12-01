Feature: do not render views

  By default, controller specs do not render views. This allows you specify
  which view template an action should try to render regardless of whether or
  not the template compiles cleanly.

  NOTE: unlike rspec-rails-1.x, the template must exist.

  Scenario: expect template that is rendered by controller action (passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        describe "index" do
          it "renders the index template" do
            get :index
            response.should render_template("index")
            response.body.should == ""
          end
          it "renders the widgets/index template" do
            get :index
            response.should render_template("widgets/index")
            response.body.should == ""
          end
        end
      end
      """
    When I run "rspec ./spec"
    Then the output should contain "2 examples, 0 failures"

  Scenario: expect template that is not rendered by controller action (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        describe "index" do
          it "renders the 'new' template" do
            get :index
            response.should render_template("new")
          end
        end
      end
      """
    When I run "rspec ./spec"
    Then the output should contain "1 example, 1 failure"


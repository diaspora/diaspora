Feature: views are stubbed by default

  By default, controller specs stub views with a template that renders an empty
  string instead of the views in the app. This allows you specify which view
  template an action should try to render regardless of whether the template
  compiles cleanly.

  NOTE: unlike rspec-rails-1.x, the real template must exist.

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
    When I run `rspec spec`
    Then the examples should all pass

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
    When I run `rspec spec`
    Then the output should contain "1 example, 1 failure"

  Scenario: expect empty templates to render when view path is changed at runtime (passes)
    Given a file named "spec/controllers/things_controller_spec.rb" with:
      """
      require "spec_helper"

      describe ThingsController do
        describe "custom_action" do
          it "renders an empty custom_action template" do
            controller.prepend_view_path 'app/views'
            controller.append_view_path 'app/views'
            get :custom_action
            response.should render_template("custom_action")
            response.body.should == ""
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: expect template to render when view path is changed at runtime (fails)
    Given a file named "spec/controllers/things_controller_spec.rb" with:
      """
      require "spec_helper"

      describe ThingsController do
        describe "custom_action" do
          it "renders the custom_action template" do
            render_views
            controller.prepend_view_path 'app/views'
            get :custom_action
            response.should render_template("custom_action")
            response.body.should == ""
          end

          it "renders an empty custom_action template" do
            controller.prepend_view_path 'app/views'
            get :custom_action
            response.should render_template("custom_action")
            response.body.should == ""
          end
        end
      end
      """
    When I run `rspec spec`
    Then the output should contain "2 examples, 1 failure"

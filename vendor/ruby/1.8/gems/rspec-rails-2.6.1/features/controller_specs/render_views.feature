Feature: render_views

  You can tell a controller example group to render views with the
  `render_views` declaration in any individual group, or globally.

  Scenario: render_views directly in a single group
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        render_views

        describe "GET index" do
          it "says 'Listing widgets'" do
            get :index
            response.body.should =~ /Listing widgets/m
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: render_views on and off in nested groups
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        context "with render_views" do
          render_views

          describe "GET index" do
            it "renders the actual template" do
              get :index
              response.body.should =~ /Listing widgets/m
            end
          end

          context "with render_views(false) nested in a group with render_views" do
            render_views false

            describe "GET index" do
              it "renders the RSpec generated template" do
                get :index
                response.body.should eq("")
              end
            end
          end
        end

        context "without render_views" do
          describe "GET index" do
            it "renders the RSpec generated template" do
              get :index
              response.body.should eq("")
            end
          end
        end

        context "with render_views again" do
          render_views

          describe "GET index" do
            it "renders the actual template" do
              get :index
              response.body.should =~ /Listing widgets/m
            end
          end
        end
      end
      """
    When I run `rspec spec --format documentation`
    Then the output should contain:
      """
      WidgetsController
        with render_views
          GET index
            renders the actual template
          with render_views(false) nested in a group with render_views
            GET index
              renders the RSpec generated template
        without render_views
          GET index
            renders the RSpec generated template
        with render_views again
          GET index
            renders the actual template
      """

  Scenario: render_views globally
    Given a file named "spec/support/render_views.rb" with:
      """
      RSpec.configure do |config|
        config.render_views
      end
      """
    And a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        describe "GET index" do
          it "renders the index template" do
            get :index
            response.body.should =~ /Listing widgets/m
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass
    

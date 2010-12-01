Feature: access to named routes in routing specs

  Scenario: access existing named route
    Given a file named "spec/routing/widget_routes_spec.rb" with:
      """
      require "spec_helper"

      describe "routes to the widgets controller" do
        it "routes a named route" do
          {:get => new_widget_path}.should route_to(:controller => "widgets", :action => "new")
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "1 example, 0 failures"

Feature: route_to matcher

  The `route_to` matcher specifies that a request (verb + path) is routable.
  It is most valuable when specifying routes other than standard RESTful
  routes.

      get("/").should route_to("welcome#index") # new in 2.6.0

      or

      { :get => "/" }.should route_to(:controller => "welcome")

  Scenario: passing route spec with shortcut syntax
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe "routes for Widgets" do
        it "routes /widgets to the widgets controller" do
          get("/widgets").
            should route_to("widgets#index")
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the examples should all pass

  Scenario: passing route spec with verbose syntax
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe "routes for Widgets" do
        it "routes /widgets to the widgets controller" do
          { :get => "/widgets" }.
            should route_to(:controller => "widgets", :action => "index")
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the examples should all pass

  Scenario: route spec for a route that doesn't exist (fails)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe "routes for Widgets" do
        it "routes /widgets/foo to the /foo action" do
          get("/widgets/foo").should route_to("widgets#foo")
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the output should contain "1 failure"

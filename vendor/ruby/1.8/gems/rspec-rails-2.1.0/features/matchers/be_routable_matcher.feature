Feature: be_routable matcher

  The be_routable matcher is intended for use with should_not to specify that a
  given route should_not be_routable. It is available in routing specs (in
  spec/routing) and controller specs (in spec/controller).

  Scenario: specify routeable route should be routable (passes)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "routes to /widgets" do
          { :get => "/widgets" }.should be_routable
        end
      end
      """

    When I run "rspec spec/routing/widgets_routing_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: specify routeable route should not be routable (fails)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "does not route to widgets" do
          { :get => "/widgets" }.should_not be_routable
        end
      end
      """

    When I run "rspec spec/routing/widgets_routing_spec.rb"
    Then the output should contain "1 example, 1 failure"

  Scenario: specify non-routeable route should not be routable (passes)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "does not route to widgets/foo/bar" do
          { :get => "/widgets/foo/bar" }.should_not be_routable
        end
      end
      """

    When I run "rspec spec/routing/widgets_routing_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: specify non-routeable route should be routable (fails)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "routes to widgets/foo/bar" do
          { :get => "/widgets/foo/bar" }.should be_routable
        end
      end
      """

    When I run "rspec spec/routing/widgets_routing_spec.rb"
    Then the output should contain "1 example, 1 failure"

  Scenario: be_routable in a controller spec
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "routes to /widgets" do
          { :get => "/widgets" }.should be_routable
        end
      end
      """

    When I run "rspec spec/controllers/widgets_controller_spec.rb"
    Then the output should contain "1 example, 0 failures"

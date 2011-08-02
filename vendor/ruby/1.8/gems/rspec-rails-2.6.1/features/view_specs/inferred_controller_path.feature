Feature: view spec infers controller path and action

  Scenario: infer controller path
    Given a file named "spec/views/widgets/new.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/new.html.erb" do
        it "infers the controller path" do
          controller.request.path_parameters["controller"].should eq("widgets")
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: infer action
    Given a file named "spec/views/widgets/new.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/new.html.erb" do
        it "infers the controller path" do
          controller.request.path_parameters["action"].should eq("new")
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: do not infer action in a partial
    Given a file named "spec/views/widgets/_form.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/_form.html.erb" do
        it "includes a link to new" do
          controller.request.path_parameters["action"].should be_nil
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass


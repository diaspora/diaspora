Feature: helper spec
  
  Helper specs live in `spec/helpers`, or any example group with `:type =>
  :helper`.

  Helper specs expose a `helper` object, which includes the helper module being
  specified, the `ApplicationHelper` module (if there is one) and all of the
  helpers built into Rails. It does not include the other helper modules in
  your app.

  To access the helper methods you're specifying, simply call them directly
  on the `helper` object.

  NOTE: helper methods defined in controllers are not included.
  
  Scenario: helper method that returns a value
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """
      require "spec_helper"
      
      describe ApplicationHelper do
        describe "#page_title" do
          it "returns the default title" do
            helper.page_title.should eq("RSpec is your friend")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def page_title
          "RSpec is your friend"
        end
      end
      """
    When I run `rspec spec/helpers/application_helper_spec.rb`
    Then the examples should all pass
    
  Scenario: helper method that accesses an instance variable
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """
      require "spec_helper"

      describe ApplicationHelper do
        describe "#page_title" do
          it "returns the instance variable" do
            assign(:title, "My Title")
            helper.page_title.should eql("My Title")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def page_title
          @title || nil
        end
      end
      """
    When I run `rspec spec/helpers/application_helper_spec.rb`
    Then the examples should all pass

  Scenario: application helper is included in helper object
    Given a file named "spec/helpers/widgets_helper_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsHelper do
        describe "#page_title" do
          it "includes the app name" do
            assign(:title, "This Page")
            helper.page_title.should eq("The App: This Page")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def app_name
          "The App"
        end
      end
      """
    And a file named "app/helpers/widgets_helper.rb" with:
      """
      module WidgetsHelper
        def page_title
          "#{app_name}: #{@title}"
        end
      end
      """
    When I run `rspec spec/helpers/widgets_helper_spec.rb`
    Then the examples should all pass

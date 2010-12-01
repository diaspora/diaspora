Feature: helper spec
  
  Helper specs live in spec/helpers. In order to access
  the helper methods you can call them on the "helper" object.
  
  Scenario: helper method that returns true
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """
      require "spec_helper"
      
      describe ApplicationHelper do
        describe "#page_title" do
          it "returns true" do
            helper.page_title.should be_true
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def page_title
          true
        end
      end
      """
    When I run "rspec spec/helpers/application_helper_spec.rb"
    Then the output should contain "1 example, 0 failures"
    
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
    When I run "rspec spec/helpers/application_helper_spec.rb"
    Then the output should contain "1 example, 0 failures"
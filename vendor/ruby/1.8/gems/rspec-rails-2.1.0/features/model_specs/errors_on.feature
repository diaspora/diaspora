Feature: errors_on

  Scenario: with one validation error
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
        validates_presence_of :name
      end

      describe ValidatingWidget do
        it "fails validation with no name (using error_on)" do
          ValidatingWidget.new.should have(1).error_on(:name)
        end

        it "fails validation with no name (using errors_on)" do
          ValidatingWidget.new.should have(1).errors_on(:name)
        end

        it "passes validation with a name (using 0)" do
          ValidatingWidget.new(:name => "liquid nitrogen").should have(0).errors_on(:name)
        end

        it "passes validation with a name (using :no)" do
          ValidatingWidget.new(:name => "liquid nitrogen").should have(:no).errors_on(:name)
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"

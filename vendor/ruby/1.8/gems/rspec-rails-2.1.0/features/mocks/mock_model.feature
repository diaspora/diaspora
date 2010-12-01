Feature: mock_model

  The mock_model method generates a test double object that acts like an
  Active Model model. This is different from the stub_model method which
  generates an instance of a real ActiveModel class.

  The benefit of mock_model over stub_model is that its a true double, so the
  examples are not dependent on the behaviour (or mis-behaviour), or even the
  existence of any other code. If you're working on a controller spec and you
  need a model that doesn't exist, you can pass mock_model a string and the
  generated object will act as though its an instance of the class named by
  that string.
   
  Scenario: passing a string that represents a non-existent constant
    Given a file named "spec/models/car_spec.rb" with:
      """
      require "spec_helper"

      describe "mock_model('Car') with no Car constant in existence" do
        it "generates a constant" do
          Object.const_defined?(:Car).should be_false
          mock_model("Car")
          Object.const_defined?(:Car).should be_true
        end

        describe "generates an object that ..." do
          it "returns the correct name" do
            car = mock_model("Car")
            car.class.name.should eq("Car")
          end

          it "says it is a Car" do
            car = mock_model("Car")
            car.should be_a(Car)
          end
        end
      end
      """
    When I run "rspec spec/models/car_spec.rb"
    Then the output should contain "3 examples, 0 failures"

  Scenario: passing a string that represents an existing constant
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        it "uses the existing constant" do
          widget = mock_model("Widget")
          widget.should be_a(Widget)
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: passing a class that does not extend ActiveModel::Naming
    Given a file named "spec/models/string_spec.rb" with:
      """
      require "spec_helper"

      describe String do
        it "raises" do
          expect { mock_model(String) }.to raise_exception
        end
      end
      """
    When I run "rspec spec/models/string_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: passing an Active Record constant
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        let(:widget) { mock_model(Widget) }

        it "is valid by default" do
          widget.should be_valid
        end

        it "is not a new record by default" do
          widget.should_not be_new_record
        end

        it "can be converted to a new record" do
          widget.as_new_record.should be_new_record
        end

        it "sets :id to nil upon destroy" do
          widget.destroy
          widget.id.should be_nil
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"

  Scenario: passing an Active Record constant with method stubs
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe "mock_model(Widget) with stubs" do
        let(:widget) do
          mock_model Widget, :foo => "bar",
                             :save => true,
                             :update_attributes => false
        end

        it "supports stubs for methods that don't exist in ActiveModel or ActiveRecord" do
          widget.foo.should eq("bar")
        end

        it "supports stubs for methods that do exist" do
          widget.save.should eq(true)
          widget.update_attributes.should be_false
        end

        describe "#errors" do
          context "with update_attributes => false" do
            it "is not empty" do
              widget.errors.should_not be_empty
            end
          end
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "3 examples, 0 failures"

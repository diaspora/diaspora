Feature: stub_model
  
  The stub_model method generates an instance of a Active Model model.
  
  While you can use stub_model in any example (model, view, controller,
  helper), it is especially useful in view examples, which are inherently
  more state-based than interaction-based.
   
  Scenario: passing an Active Record constant with a hash of stubs
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe "stub_model(Widget) with a hash of stubs" do
        let(:widget) do
          stub_model Widget, :id => 5, :random_attribute => true
        end
        
        it "stubs :id" do
          widget.id.should eql(5)
        end
        
        it "stubs :random_attribute" do
          widget.random_attribute.should be_true
        end
        
        it "returns false for new_record? if :id is set" do
          widget.should_not be_new_record
        end
        
        it "can be converted to a new record" do
          widget.as_new_record
          widget.should be_new_record
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"
    
  Scenario: passing an Active Record constant with a block of stubs
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe "stub_model(Widget) with a block of stubs" do
        let(:widget) do
          stub_model Widget do |widget|
            widget.id = 5
          end
        end
        
        it "stubs :id" do
          widget.id.should eql(5)
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "1 example, 0 failures"
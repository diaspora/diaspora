Feature: stub template

  In order to isolate view specs from the partials rendered by the primary
  view, rspec-rails (since 2.2) provides the stub_template method.

  Scenario: stub template that does not exist
    Given a file named "spec/views/gadgets/list.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "gadgets/list.html.erb" do
        it "renders the gadget partial for each gadget" do
          assign(:gadgets, [
            mock_model(Gadget, :id => 1, :name => "First"),
            mock_model(Gadget, :id => 2, :name => "Second")
          ])
          stub_template "gadgets/_gadget.html.erb" => "<%= gadget.name %><br/>"
          render
          rendered.should =~ /First/
          rendered.should =~ /Second/
        end
      end
      """

    And a file named "app/views/gadgets/list.html.erb" with:
      """
      <%= render :partial => "gadget", :collection => @gadgets %>
      """
    When I run `rspec spec/views/gadgets/list.html.erb_spec.rb`
    Then the examples should all pass

  Scenario: stub template that exists
    Given a file named "spec/views/gadgets/edit.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "gadgets/edit.html.erb" do
        before(:each) do
          @gadget = assign(:gadget, stub_model(Gadget))
        end

        it "renders the form partial" do
          stub_template "gadgets/_form.html.erb" => "This content"
          render
          rendered.should =~ /This content/
        end
      end
      """
    When I run `rspec spec/views/gadgets/edit.html.erb_spec.rb`
    Then the examples should all pass


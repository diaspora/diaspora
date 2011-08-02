Feature: redirect_to matcher

  The `redirect_to` matcher is used to specify that a request redirects to a
  given template or action.  It delegates to
  [`assert_redirected_to`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to).

  It is available in controller specs (spec/controllers) and request
  specs (spec/requests).

  Scenario: redirect_to with four possible options
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do

        describe "#create" do
          subject { post :create, :widget => { :name => "Foo" } }

          it "redirects to widget_url(@widget)" do
            subject.should redirect_to(widget_url(assigns(:widget)))
          end

          it "redirects_to :action => :show" do
            subject.should redirect_to :action => :show,
                                       :id => assigns(:widget).id
          end

          it "redirects_to(@widget)" do
            subject.should redirect_to(assigns(:widget))
          end

          it "redirects_to /widgets/:id" do
            subject.should redirect_to("/widgets/#{assigns(:widget).id}")
          end
        end
      end
      """
    When I run `rspec spec/controllers/widgets_controller_spec.rb`
    Then the examples should all pass

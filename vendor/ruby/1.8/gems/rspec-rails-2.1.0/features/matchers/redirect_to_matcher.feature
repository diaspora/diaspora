Feature: redirect_to matcher

  The redirect_to matcher is used to specify that the redirect called
  in the latest action ended with the intended behaviour. Essentially,
  it delegates to "assert_redirect". For more info, please check out
  the Rails documentation on this method.

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
    When I run "rspec spec/controllers/widgets_controller_spec.rb"
    Then the output should contain "4 examples, 0 failures"
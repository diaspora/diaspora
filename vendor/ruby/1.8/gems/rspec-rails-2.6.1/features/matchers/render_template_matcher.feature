Feature: render_template matcher

  The `render_template` matcher is used to specify that a request renders a
  given template.  It delegates to
  [`assert_template`](http://api.rubyonrails.org/classes/ActionController/TemplateAssertions.html#method-i-assert_template)

  It is available in controller specs (spec/controllers) and request
  specs (spec/requests).

  NOTE: use `redirect_to(:action => 'new')` for redirects, not `render_template`.

  Scenario: render_template with three possible options
    Given a file named "spec/controllers/gadgets_spec.rb" with:
      """
      require "spec_helper"

      describe GadgetsController do
        describe "GET #index" do
          subject { get :index }

          it { should render_template(:index) }
          it { should render_template("index") }
          it { should render_template("gadgets/index") }
        end
      end
      """
    When I run `rspec spec/controllers/gadgets_spec.rb`
    Then the examples should all pass

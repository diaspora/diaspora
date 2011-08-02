module RSpec::Rails
  # Extends ActionController::TestCase::Behavior to work with RSpec.
  #
  # == Examples
  #
  # == with stubs
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       it "assigns all widgets to @widgets" do
  #         widget = stub_model(Widget)
  #         Widget.stub(:all) { widget }
  #         get :index
  #         assigns(:widgets).should eq([widget])
  #       end
  #     end
  #   end
  #
  # === with a factory
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       it "assigns all widgets to @widgets" do
  #         widget = Factory(:widget)
  #         get :index
  #         assigns(:widgets).should eq([widget])
  #       end
  #     end
  #   end
  #
  # === with fixtures
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       fixtures :widgets
  #
  #       it "assigns all widgets to @widgets" do
  #         get :index
  #         assigns(:widgets).should eq(Widget.all)
  #       end
  #     end
  #   end
  #
  # == Matchers
  #
  # In addition to the stock matchers from rspec-expectations, controller
  # specs add these matchers, which delegate to rails' assertions:
  #
  #   response.should render_template(*args)
  #   => delegates to assert_template(*args)
  #
  #   response.should redirect_to(destination)
  #   => delegates to assert_redirected_to(destination)
  #
  # == Isolation from views
  #
  # RSpec's preferred approach to spec'ing controller behaviour is to isolate
  # the controller from its collaborators.  By default, therefore, controller
  # example groups do not render the views in your app. Due to the way Rails
  # searches for view templates, the template still needs to exist, but it
  # won't actually be loaded.
  #
  # NOTE that this is different from rspec-rails-1 with rails-2, which did not
  # require the presence of the file at all. Due to changes in rails-3, this
  # was no longer feasible in rspec-rails-2.
  #
  # == View rendering
  #
  # If you prefer a more integrated approach, similar to that of Rails'
  # functional tests, you can tell controller groups to render the views in the
  # app with the +render_views+ declaration:
  #
  #   describe WidgetsController do
  #     render_views
  #     ...
  #
  module ControllerExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionController::TestCase::Behavior
    include RSpec::Rails::ViewRendering
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include RSpec::Rails::Matchers::RoutingMatchers

    module ClassMethods
      def controller_class
        describes
      end

      # Supports a simple DSL for specifying behaviour of
      # ApplicationController.  Creates an anonymous subclass of
      # ApplicationController and evals the +body+ in that context. Also sets
      # up implicit routes for this controller, that are separate from those
      # defined in <tt>config/routes.rb</tt>.
      #
      # == Examples
      #
      #    describe ApplicationController do
      #      controller do
      #        def index
      #          raise ApplicationController::AccessDenied
      #        end
      #      end
      #
      #      describe "handling AccessDenied exceptions" do
      #        it "redirects to the /401.html page" do
      #          get :index
      #          response.should redirect_to("/401.html")
      #        end
      #      end
      #    end
      #
      # If you would like to spec a subclass of ApplicationController, call
      # controller like so:
      #
      #    controller(ApplicationControllerSubclass) do
      #      # ....
      #    end
      #
      # NOTICE: Due to Ruby 1.8 scoping rules in anoymous subclasses, constants
      # defined in +ApplicationController+ must be fully qualified (e.g.
      # ApplicationController::AccessDenied) in the block passed to the
      # +controller+ method. Any instance methods, filters, etc, that are
      # defined in +ApplicationController+, however, are accessible from within
      # the block.
      def controller(base_class = ApplicationController, &body)
        metadata[:example_group][:describes] = Class.new(base_class, &body)
        metadata[:example_group][:describes].singleton_class.class_eval do
          def name; "AnonymousController" end
        end

        before do
          @orig_routes, @routes = @routes, ActionDispatch::Routing::RouteSet.new
          @routes.draw { resources :anonymous }
        end

        after do
          @routes, @orig_routes = @orig_routes, nil
        end
      end
    end

    module InstanceMethods
      attr_reader :controller, :routes

      def method_missing(method, *args, &block)
        if @orig_routes && @orig_routes.named_routes.helpers.include?(method)
          controller.send(method, *args, &block)
        else
          super
        end
      end
    end

    included do
      subject { controller }

      metadata[:type] = :controller

      before do
        @routes = ::Rails.application.routes
        ActionController::Base.allow_forgery_protection = false
      end
    end
  end
end

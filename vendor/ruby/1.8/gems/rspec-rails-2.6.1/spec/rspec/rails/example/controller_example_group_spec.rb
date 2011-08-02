require "spec_helper"

module RSpec::Rails
  describe ControllerExampleGroup do
    it { should be_included_in_files_in('./spec/controllers/') }
    it { should be_included_in_files_in('.\\spec\\controllers\\') }

    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
    end

    it "includes routing matchers" do
      group.included_modules.should include(RSpec::Rails::Matchers::RoutingMatchers)
    end

    it "adds :type => :controller to the metadata" do
      group.metadata[:type].should eq(:controller)
    end

    context "with implicit subject" do
      it "uses the controller as the subject" do
        controller = double('controller')
        example = group.new
        example.stub(:controller => controller)
        example.subject.should == controller
      end
    end

    describe "with explicit subject" do
      it "should use the specified subject instead of the controller" do
        group.subject { 'explicit' }
        example = group.new
        example.subject.should == 'explicit'
      end
    end

    describe "with anonymous controller" do
      before do
        group.class_eval do
          controller(Class.new) { }
        end
      end

      it "delegates named route helpers to the underlying controller" do
        controller = double('controller')
        controller.stub(:foos_url).and_return('http://test.host/foos')

        example = group.new
        example.stub(:controller => controller)

        # As in the routing example spec, this is pretty invasive, but not sure
        # how to do it any other way as the correct operation relies on before
        # hooks
        routes = ActionDispatch::Routing::RouteSet.new
        routes.draw { resources :foos }
        example.instance_variable_set(:@orig_routes, routes)

        example.foos_url.should eq('http://test.host/foos')
      end
    end
  end
end

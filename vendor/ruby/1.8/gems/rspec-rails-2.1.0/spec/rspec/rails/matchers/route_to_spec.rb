require "spec_helper"

describe "route_to" do
  include RSpec::Rails::Matchers::RoutingMatchers

  it "uses failure message from assert_recognizes" do
    self.stub!(:assert_recognizes).and_raise(
      Test::Unit::AssertionFailedError.new("this message"))
    expect do
      {"this" => "path"}.should route_to("these" => "options")
    end.to raise_error("this message")
  end
end

describe "be_routable" do
  include RSpec::Rails::Matchers::RoutingMatchers
  attr_reader :routes

  before { @routes = double("routes") }

  context "with should" do
    it "passes if routes recognize the path" do
      routes.stub(:recognize_path) { {} }
      expect do
        {:get => "/a/path"}.should be_routable
      end.to_not raise_error
    end

    it "fails if routes do not recognize the path" do
      routes.stub(:recognize_path) { raise ActionController::RoutingError.new('ignore') }
      expect do
        {:get => "/a/path"}.should be_routable
      end.to raise_error(/expected \{:get=>"\/a\/path"\} to be routable/)
    end
  end

  context "with should_not" do

    it "passes if routes do not recognize the path" do
      routes.stub(:recognize_path) { raise ActionController::RoutingError.new('ignore') }
      expect do
        {:get => "/a/path"}.should_not be_routable
      end.to_not raise_error
    end

    it "fails if routes recognize the path" do
      routes.stub(:recognize_path) { {:controller => "foo"} }
      expect do
        {:get => "/a/path"}.should_not be_routable
      end.to raise_error(/expected \{:get=>"\/a\/path"\} not to be routable, but it routes to \{:controller=>"foo"\}/)
    end
  end
end

require "spec_helper"

describe "route_to" do
  include RSpec::Rails::Matchers::RoutingMatchers
  include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers

  it "delegates to assert_recognizes" do
    self.should_receive(:assert_recognizes).with({ "these" => "options" }, { :method=> :get, :path=>"path" })
    {:get => "path"}.should route_to("these" => "options")
  end

  context "with shortcut syntax" do

    it "routes with extra options" do
      self.should_receive(:assert_recognizes).with({ :controller => "controller", :action => "action", :extra => "options"}, { :method=> :get, :path=>"path" })
      get("path").should route_to("controller#action", :extra => "options")
    end

    it "routes without extra options" do
      self.should_receive(:assert_recognizes).with({ :controller => "controller", :action => "action"}, { :method=> :get, :path=>"path" })
      get("path").should route_to("controller#action")
    end

  end

  context "with should" do
    context "when assert_recognizes passes" do
      it "passes" do
        self.stub!(:assert_recognizes)
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to_not raise_exception
      end
    end

    context "when assert_recognizes fails" do
      it "fails with message from assert_recognizes" do
        self.stub!(:assert_recognizes) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to raise_error("this message")
      end
    end

    context "when an exception is raised" do
      it "raises that exception" do
        self.stub!(:assert_recognizes) do
          raise "oops"
        end
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to raise_exception("oops")
      end
    end
  end

  context "with should_not" do
    context "when assert_recognizes passes" do
      it "fails with custom message" do
        self.stub!(:assert_recognizes)
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to raise_error(/expected .* not to route to .*/)
      end
    end

    context "when assert_recognizes fails" do
      it "passes" do
        self.stub!(:assert_recognizes) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to_not raise_error
      end
    end

    context "when an exception is raised" do
      it "raises that exception" do
        self.stub!(:assert_recognizes) do
          raise "oops"
        end
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to raise_exception("oops")
      end
    end
  end
  it "uses failure message from assert_recognizes" do
    self.stub!(:assert_recognizes).and_raise(
      ActiveSupport::TestCase::Assertion.new("this message"))
    expect do
      {"this" => "path"}.should route_to("these" => "options")
    end.to raise_error("this message")
  end
end


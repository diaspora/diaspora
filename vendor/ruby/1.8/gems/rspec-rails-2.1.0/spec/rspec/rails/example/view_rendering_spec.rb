require "spec_helper"

module RSpec::Rails
  describe ViewRendering do
    it "doesn't render views by default" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(true)
        end
        include ViewRendering
        it("does something") do
          rendering_views = render_views?
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_false
    end

    it "doesn't render views by default in a nested group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(true)
        end
        include ViewRendering
        describe "nested" do
          it("does something") do
            rendering_views = render_views?
          end
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_false
    end

    it "renders views if controller does not respond to view_paths (ActionController::Metal)" do
      rendering_views = false
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(false)
        end
        include ViewRendering
        it("does something") do
          rendering_views = render_views?
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end

    it "renders views if told to" do
      rendering_views = false
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(true)
        end
        include ViewRendering
        render_views
        it("does something") do
          rendering_views = render_views?
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end

    it "renders views if told to in a nested group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(true)
        end
        include ViewRendering
        describe "nested" do
          render_views
          it("does something") do
            rendering_views = render_views?
          end
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end

    it "renders views in a nested group if told to in an outer group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        before(:each) do
          @controller = double("controller")
          @controller.stub_chain("class.respond_to?").and_return(true)
        end
        include ViewRendering
        render_views
        describe "nested" do
          it("does something") do
            rendering_views = render_views?
          end
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end
  end
end

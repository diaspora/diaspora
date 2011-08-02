require "spec_helper"

module RSpec::Rails
  describe ViewRendering do
    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        def controller
          ActionController::Base.new
        end
        include ViewRendering
      end
    end

    context "default" do
      context "ActionController::Base" do
        it "does not render views" do
          group.new.render_views?.should be_false
        end

        it "does not render views in a nested group" do
          group.describe{}.new.render_views?.should be_false
        end
      end

      context "ActionController::Metal" do
        it "renders views" do
          group.new.tap do |example|
            def example.controller
              ActionController::Metal.new
            end
            example.render_views?.should be_true
          end
        end
      end
    end

    describe "#render_views" do
      context "with no args" do
        it "tells examples to render views" do
          group.render_views
          group.new.render_views?.should be_true
        end
      end

      context "with true" do
        it "tells examples to render views" do
          group.render_views true
          group.new.render_views?.should be_true
        end
      end

      context "with false" do
        it "tells examples not to render views" do
          group.render_views false
          group.new.render_views?.should be_false
        end
      end

      context "in a nested group" do
        let(:nested_group) do
          group.describe{}
        end

        context "with no args" do
          it "tells examples to render views" do
            nested_group.render_views
            nested_group.new.render_views?.should be_true
          end
        end

        context "with true" do
          it "tells examples to render views" do
            nested_group.render_views true
            nested_group.new.render_views?.should be_true
          end
        end

        context "with false" do
          it "tells examples not to render views" do
            nested_group.render_views false
            nested_group.new.render_views?.should be_false
          end
        end

        it "leaves the parent group as/is" do
          group.render_views
          nested_group.render_views false
          group.new.render_views?.should be_true
        end

        it "overrides the value inherited from the parent group" do
          group.render_views
          nested_group.render_views false
          nested_group.new.render_views?.should be_false
        end

        it "passes override to children" do
          group.render_views
          nested_group.render_views false
          nested_group.describe{}.new.render_views?.should be_false
        end
      end
    end
  end
end

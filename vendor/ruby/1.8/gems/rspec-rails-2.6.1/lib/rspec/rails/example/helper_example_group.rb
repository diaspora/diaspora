require 'rspec/rails/view_assigns'

module RSpec::Rails
  # Extends ActionView::TestCase::Behavior
  #
  # == Examples
  #
  #   describe RoleBasedDisplayHelper do
  #     describe "display_for" do
  #       context "given the role of the current user" do
  #         it "yields to the block" do
  #           helper.stub(:current_user) { double(:roles => ['admin'] }
  #           text = helper.display_for('admin') { "this text" }
  #           text.should eq("this text")
  #         end
  #       end
  #
  #       context "given a different role that that of the current user" do
  #         it "renders an empty String" do
  #           helper.stub(:current_user) { double(:roles => ['manager'] }
  #           text = helper.display_for('admin') { "this text" }
  #           text.should eq("")
  #         end
  #       end
  #     end
  #   end
  #
  module HelperExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionView::TestCase::Behavior
    include RSpec::Rails::ViewAssigns

    module ClassMethods
      def determine_default_helper_class(ignore)
        describes
      end
    end

    module InstanceMethods
      # Returns an instance of ActionView::Base with the helper being specified
      # mixed in, along with any of the built-in rails helpers.
      def helper
        _view.tap do |v|
          v.extend(ApplicationHelper) if defined?(ApplicationHelper)
          v.assign(view_assigns)
        end
      end

    private

      def _controller_path
        example.example_group.describes.to_s.sub(/Helper/,'').underscore
      end
    end

    included do
      metadata[:type] = :helper

      before do
        controller.controller_path = _controller_path
      end
    end
  end
end

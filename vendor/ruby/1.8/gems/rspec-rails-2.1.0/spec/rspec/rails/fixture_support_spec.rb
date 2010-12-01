require "spec_helper"

module RSpec::Rails
  describe FixtureSupport do
    context "with use_transactional_fixtures set to false" do
      it "still supports fixture_path" do
        RSpec.configuration.stub(:use_transactional_fixtures) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        group.should respond_to(:fixture_path)
        group.should respond_to(:fixture_path=)
      end
    end
  end
end

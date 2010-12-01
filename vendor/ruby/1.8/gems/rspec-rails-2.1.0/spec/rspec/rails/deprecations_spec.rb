require 'spec_helper'

describe "rspec-rails-2 deprecations" do
  context "controller specs" do
    describe "::integrate_views" do
      let(:group) do
        RSpec::Core::ExampleGroup.describe do
          include RSpec::Rails::ControllerExampleGroup
        end
      end

      it "is deprecated" do
        RSpec.should_receive(:deprecate)
        group.integrate_views
      end
    end
  end
end

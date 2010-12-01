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
  end
end

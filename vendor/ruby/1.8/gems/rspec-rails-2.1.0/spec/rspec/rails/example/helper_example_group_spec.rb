require "spec_helper"

module RSpec::Rails
  describe HelperExampleGroup::InstanceMethods do
    module ::FoosHelper; end
    subject { HelperExampleGroup }

    it { should be_included_in_files_in('./spec/helpers/') }
    it { should be_included_in_files_in('.\\spec\\helpers\\') }

    it "provides a controller_path based on the helper module's name" do
      helper_spec = Object.new.extend HelperExampleGroup::InstanceMethods
      helper_spec.stub_chain(:example, :example_group, :describes).and_return(FoosHelper)
      helper_spec.__send__(:_controller_path).should == "foos"
    end

    it "adds :type => :helper to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include HelperExampleGroup
      end
      group.metadata[:type].should eq(:helper)
    end

    describe "#helper" do
      it "returns the instance of AV::Base provided by AV::TC::Behavior" do
        helper_spec = Object.new.extend HelperExampleGroup::InstanceMethods
        helper_spec.should_receive(:view_assigns)
        av_tc_b_view = double('_view')
        av_tc_b_view.should_receive(:assign)
        helper_spec.stub(:_view) { av_tc_b_view }
        helper_spec.helper.should eq(av_tc_b_view)
      end
    end
  end

  describe HelperExampleGroup::ClassMethods do
    describe "determine_default_helper_class" do
      it "returns the helper module passed to describe" do
        helper_spec = Object.new.extend HelperExampleGroup::ClassMethods
        helper_spec.stub(:describes) { FoosHelper }
        helper_spec.determine_default_helper_class("ignore this").
          should eq(FoosHelper)
      end
    end
  end
end

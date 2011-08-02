require 'spec_helper'

describe RSpec::Core do

  describe "#configuration" do

    it "returns the same object every time" do
      RSpec.configuration.should equal(RSpec.configuration)
    end

  end

  describe "#configure" do
    around(:each) do |example|
      RSpec.allowing_configure_warning(&example)
    end

    before(:each) do
      RSpec.stub(:warn)
    end

    it "yields the current configuration" do
      RSpec.configure do |config|
        config.should == RSpec::configuration
      end
    end

    context "when an example group has already been defined" do
      before(:each) do
        RSpec.world.stub(:example_groups).and_return([double.as_null_object])
      end

      it "prints a deprecation warning" do
        RSpec.should_receive(:warn).with(/configuration should happen before the first example group/)
        RSpec.configure { |c| }
      end
    end

    context "when no examples have been defined yet" do
      before(:each) do
        RSpec.world.stub(:example_groups).and_return([])
      end

      it "does not print a deprecation warning" do
        RSpec.should_not_receive(:warn)
        RSpec.configure { |c| }
      end
    end
  end

  describe "#world" do

    it "returns the RSpec::Core::World instance the current run is using" do
      RSpec.world.should be_instance_of(RSpec::Core::World)
    end

  end

end

require 'spec_helper'

describe RSpec::Core do

  describe "#configuration" do

    it "returns the same object every time" do
      RSpec.configuration.should equal(RSpec.configuration)
    end

  end

  describe "#configure" do

    it "yields the current configuration" do
      RSpec.configure do |config|
        config.should == RSpec::configuration
      end
    end

  end

  describe "#world" do

    it "returns the RSpec::Core::World instance the current run is using" do
      RSpec.world.should be_instance_of(RSpec::Core::World)
    end

  end

end

require "spec_helper"

describe "deprecations" do
  describe "Spec" do
    it "is deprecated" do
      RSpec.should_receive(:warn_deprecation).with(/Spec .* RSpec/i)
      Spec
    end

    it "returns RSpec" do
      RSpec.stub(:warn_deprecation)
      Spec.should == RSpec
    end
  end

  describe RSpec::Core::ExampleGroup do
    describe 'running_example' do
      it 'is deprecated' do
        RSpec.should_receive(:warn_deprecation)
        self.running_example
      end

      it "delegates to example" do
        RSpec.stub(:warn_deprecation)
        running_example.should == example
      end
    end
  end

  describe "Spec::Runner.configure" do
    it "is deprecated" do
      RSpec.stub(:warn_deprecation)
      RSpec.should_receive(:deprecate)
      Spec::Runner.configure
    end
  end

  describe "Spec::Rake::SpecTask" do
    it "is deprecated" do
      RSpec.stub(:warn_deprecation)
      RSpec.should_receive(:deprecate)
      Spec::Rake::SpecTask
    end
  end
end

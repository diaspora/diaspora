require "spec_helper"

describe RSpec::Core::SharedContext do
  describe "hooks" do
    it "creates a before hook" do
      before_all_hook = false
      before_each_hook = false
      after_each_hook = false
      after_all_hook = false
      shared = Module.new do
        extend RSpec::Core::SharedContext
        before(:all) { before_all_hook = true }
        before(:each) { before_each_hook = true }
        after(:each)  { after_each_hook = true }
        after(:all)  { after_all_hook = true }
      end
      group = RSpec::Core::ExampleGroup.describe do
        include shared
        example { }
      end

      group.run

      before_all_hook.should be_true
      before_each_hook.should be_true
      after_each_hook.should be_true
      after_all_hook.should be_true
    end
  end
end

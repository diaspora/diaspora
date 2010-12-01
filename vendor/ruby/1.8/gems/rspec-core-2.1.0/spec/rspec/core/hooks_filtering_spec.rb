require "spec_helper"

module RSpec::Core
  describe "config block hook filtering" do
    describe "unfiltered hooks" do
      it "should be ran" do
        filters = []
        RSpec.configure do |c|
          c.before(:all) { filters << "before all in config"}
          c.around(:each) {|example| filters << "around each in config"; example.run}
          c.before(:each) { filters << "before each in config"}
          c.after(:each) { filters << "after each in config"}
          c.after(:all) { filters << "after all in config"}
        end
        group = ExampleGroup.describe
        group.example("example") {}
        group.run
        filters.should == [
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ]
      end
    end

    describe "hooks with single filters" do

      context "with no scope specified" do
        it "should be ran around|before|after :each if the filter matches the example group's filter" do
          filters = []
          RSpec.configure do |c|
            c.around(:match => true) {|example| filters << "around each in config"; example.run}
            c.before(:match => true) { filters << "before each in config"}
            c.after(:match => true)  { filters << "after each in config"}
          end
          group = ExampleGroup.describe(:match => true)
          group.example("example") {}
          group.run
          filters.should == [
            "around each in config",
            "before each in config",
            "after each in config"
          ]
        end
      end

      it "should be ran if the filter matches the example group's filter" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :match => true) { filters << "before all in config"}
          c.around(:each, :match => true) {|example| filters << "around each in config"; example.run}
          c.before(:each, :match => true) { filters << "before each in config"}
          c.after(:each,  :match => true) { filters << "after each in config"}
          c.after(:all,   :match => true) { filters << "after all in config"}
        end
        group = ExampleGroup.describe(:match => true)
        group.example("example") {}
        group.run
        filters.should == [
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ]
      end

      it "should not be ran if the filter doesn't match the example group's filter" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :match => false) { filters << "before all in config"}
          c.around(:each, :match => false) {|example| filters << "around each in config"; example.run}
          c.before(:each, :match => false) { filters << "before each in config"}
          c.after(:each,  :match => false) { filters << "after each in config"}
          c.after(:all,   :match => false) { filters << "after all in config"}
        end
        group = ExampleGroup.describe(:match => true)
        group.example("example") {}
        group.run
        filters.should == []
      end
    end

    describe "hooks with multiple filters" do
      it "should be ran if all hook filters match the group's filters" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :one => 1)                         { filters << "before all in config"}
          c.around(:each, :two => 2, :one => 1)              {|example| filters << "around each in config"; example.run}
          c.before(:each, :one => 1, :two => 2)              { filters << "before each in config"}
          c.after(:each,  :one => 1, :two => 2, :three => 3) { filters << "after each in config"}
          c.after(:all,   :one => 1, :three => 3)            { filters << "after all in config"}
        end
        group = ExampleGroup.describe(:one => 1, :two => 2, :three => 3)
        group.example("example") {}
        group.run
        filters.should == [
          "before all in config",
          "around each in config",
          "before each in config",
          "after each in config",
          "after all in config"
        ]
      end

      it "should not be ran if some hook filters don't match the group's filters" do
        filters = []
        RSpec.configure do |c|
          c.before(:all,  :one => 1, :four => 4)                         { filters << "before all in config"}
          c.around(:each, :two => 2, :four => 4)                         {|example| filters << "around each in config"; example.run}
          c.before(:each, :one => 1, :two => 2, :four => 4)              { filters << "before each in config"}
          c.after(:each,  :one => 1, :two => 2, :three => 3, :four => 4) { filters << "after each in config"}
          c.after(:all,   :one => 1, :three => 3, :four => 4)            { filters << "after all in config"}
        end
        group = ExampleGroup.describe(:one => 1, :two => 2, :three => 3)
        group.example("example") {}
        group.run
        filters.should == []
      end
    end
  end
end

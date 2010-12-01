require 'spec_helper'

class Bar; end
class Foo; end

module RSpec::Core

  describe World do
    let(:world) { RSpec::Core::World.new }

    describe "#example_groups" do
      it "contains all registered example groups" do
        group = RSpec::Core::ExampleGroup.describe("group"){}
        world.register(group)
        world.example_groups.should include(group)
      end
    end

    describe "#apply_inclusion_filters" do
      let(:group1) { 
        RSpec::Core::ExampleGroup.describe(Bar, "find group-1", 
          { :foo => 1, :color => 'blue', :feature => 'reporting' }
        ) {}
      }

      let(:group2) {
        RSpec::Core::ExampleGroup.describe(Bar, "find group-2",
          { :pending => true, :feature => 'reporting' }
        ) {}
      }

      let(:group3) {
        RSpec::Core::ExampleGroup.describe(Bar, "find group-3", 
          { :array => [1,2,3,4], :color => 'blue' }
        ) {}
      }

      let(:group4) {
        RSpec::Core::ExampleGroup.describe(Foo, "find these examples") do
          it('I have no options') {}
          it("this is awesome", :awesome => true) {}
          it("this is too", :awesome => true) {}
          it("not so awesome", :awesome => false) {}
          it("I also have no options") {}
        end
      }
      
      let(:example_groups) { [group1, group2, group3, group4] }

      it "finds no groups when given no search parameters" do
        world.apply_inclusion_filters([]).should == []
      end

      it "finds matching groups when filtering on :describes (described class or module)" do
        world.apply_inclusion_filters(example_groups, :example_group => { :describes => Bar }).should == [group1, group2, group3]
      end

      it "finds matching groups when filtering on :description with text" do
        world.apply_inclusion_filters(example_groups, :example_group => { :description => 'Bar find group-1' }).should == [group1]
      end

      it "finds matching groups when filtering on :description with a lambda" do
        world.apply_inclusion_filters(example_groups, :example_group => { :description => lambda { |v| v.include?('-1') || v.include?('-3') } }).should == [group1, group3]
      end

      it "finds matching groups when filtering on :description with a regular expression" do
        world.apply_inclusion_filters(example_groups, :example_group => { :description => /find group/ }).should == [group1, group2, group3]
      end

      it "finds one group when searching for :pending => true" do
        world.apply_inclusion_filters(example_groups, :pending => true ).should == [group2]
      end

      it "finds matching groups when filtering on arbitrary metadata with a number" do
        world.apply_inclusion_filters(example_groups, :foo => 1 ).should == [group1]
      end

      it "finds matching groups when filtering on arbitrary metadata with an array" do
        world.apply_inclusion_filters(example_groups, :array => [1,2,3,4]).should == [group3]
      end

      it "finds no groups when filtering on arbitrary metadata with an array but the arrays do not match" do
        world.apply_inclusion_filters(example_groups, :array => [4,3,2,1]).should be_empty
      end

      it "finds matching examples when filtering on arbitrary metadata" do
        world.apply_inclusion_filters(group4.examples, :awesome => true).should == [group4.examples[1], group4.examples[2]]
      end

      it "finds matching examples for example that match any of the filters" do
        world.apply_inclusion_filters(group4.examples, :awesome => true, :something => :else).should == [group4.examples[1], group4.examples[2]]
      end
    end

    describe "#apply_exclusion_filters" do

      it "finds nothing if all describes match the exclusion filter" do
        options = { :network_access => true }

        group1 = ExampleGroup.describe(Bar, "find group-1", options) do
          it("foo") {}
          it("bar") {}
        end

        world.register(group1)

        world.apply_exclusion_filters(group1.examples, :network_access => true).should == []

        group2 = ExampleGroup.describe(Bar, "find group-1") do
          it("foo", :network_access => true) {}
          it("bar") {}
        end

        world.register(group2)

        world.apply_exclusion_filters(group2.examples, :network_access => true).should == [group2.examples.last]
      end

      it "finds nothing if a regexp matches the exclusion filter" do
        group = ExampleGroup.describe(Bar, "find group-1", :name => "exclude me with a regex", :another => "foo") do
          it("foo") {}
          it("bar") {}
        end
        world.register(group)
        world.apply_exclusion_filters(group.examples, :name => /exclude/).should == []
        world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo").should == []
        world.apply_exclusion_filters(group.examples, :name => /exclude/, :another => "foo", :example_group => {
          :describes => lambda { |b| b == Bar } } ).should == []

        world.apply_exclusion_filters(group.examples, :name => /exclude not/).should == group.examples
        world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo").should == []
        world.apply_exclusion_filters(group.examples, :name => /exclude/, "another_condition" => "foo1").should == []
      end
    end

    describe "#preceding_declaration_line (again)" do

      let(:group) do
        RSpec::Core::ExampleGroup.describe("group") do

          example("example") {}

        end
      end

      let(:group_declaration_line) { group.metadata[:example_group][:line_number] }
      let(:example_declaration_line) { group_declaration_line + 2 }

      before { world.register(group) }

      it "returns nil if no example or group precedes the line" do
        world.preceding_declaration_line(group_declaration_line - 1).should be_nil
      end

      it "returns the argument line number if a group starts on that line" do
        world.preceding_declaration_line(group_declaration_line).should eq(group_declaration_line)
      end

      it "returns the argument line number if an example starts on that line" do
        world.preceding_declaration_line(example_declaration_line).should eq(example_declaration_line)
      end

      it "returns line number of a group that immediately precedes the argument line" do
        world.preceding_declaration_line(group_declaration_line + 1).should eq(group_declaration_line)
      end

      it "returns line number of an example that immediately precedes the argument line" do
        world.preceding_declaration_line(example_declaration_line + 1).should eq(example_declaration_line)
      end
    end

  end

end

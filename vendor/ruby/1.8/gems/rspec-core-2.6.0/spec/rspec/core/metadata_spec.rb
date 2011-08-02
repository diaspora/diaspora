require 'spec_helper'

module RSpec
  module Core
    describe Metadata do

      describe "#process" do
        Metadata::RESERVED_KEYS.each do |key|
          it "prohibits :#{key} as a hash key" do
            m = Metadata.new
            expect do
              m.process('group', key => {})
            end.to raise_error(/:#{key} is not allowed/)
          end
        end

        it "uses :caller if passed as part of the user metadata" do
          m = Metadata.new
          m.process('group', :caller => ['example_file:42'])
          m[:example_group][:location].should == 'example_file:42'
        end
      end

      describe "#apply_condition" do

        let(:parent_group_metadata) { Metadata.new.process('parent group', :caller => ["foo_spec.rb:#{__LINE__}"]) }
        let(:parent_group_line_number) { parent_group_metadata[:example_group][:line_number] }
        let(:group_metadata) { Metadata.new(parent_group_metadata).process('group', :caller => ["foo_spec.rb:#{__LINE__}"]) }
        let(:group_line_number) { group_metadata[:example_group][:line_number] }
        let(:example_metadata) { group_metadata.for_example('example', :caller => ["foo_spec.rb:#{__LINE__}"], :if => true) }
        let(:example_line_number) { example_metadata[:line_number] }
        let(:next_example_metadata) { group_metadata.for_example('next_example', :caller => ["foo_spec.rb:#{example_line_number + 2}"]) }
        let(:world) { World.new }

        before { RSpec.stub(:world) { world } }

        it "matches the group when the line_number is the example group line number" do
          world.should_receive(:preceding_declaration_line).and_return(group_line_number)
          # this call doesn't really make sense since apply_condition is only called
          # for example metadata not group metadata
          group_metadata.apply_condition(:line_number, group_line_number).should be_true
        end

        it "matches the example when the line_number is the grandparent example group line number" do
          world.should_receive(:preceding_declaration_line).and_return(parent_group_line_number)
          example_metadata.apply_condition(:line_number, parent_group_line_number).should be_true
        end

        it "matches the example when the line_number is the parent example group line number" do
          world.should_receive(:preceding_declaration_line).and_return(group_line_number)
          example_metadata.apply_condition(:line_number, group_line_number).should be_true
        end

        it "matches the example when the line_number is the example line number" do
          world.should_receive(:preceding_declaration_line).and_return(example_line_number)
          example_metadata.apply_condition(:line_number, example_line_number).should be_true
        end

        it "matches when the line number is between this example and the next" do
          world.should_receive(:preceding_declaration_line).and_return(example_line_number)
          example_metadata.apply_condition(:line_number, example_line_number + 1).should be_true
        end

        it "does not match when the line number matches the next example" do
          world.should_receive(:preceding_declaration_line).and_return(example_line_number + 2)
          example_metadata.apply_condition(:line_number, example_line_number + 2).should be_false
        end

        it "matches a proc that evaluates to true" do
          example_metadata.apply_condition(:if, lambda { |v| v }).should be_true
        end

        it "does not match a proc that evaluates to false" do
          example_metadata.apply_condition(:if, lambda { |v| !v }).should be_false
        end

        it "passes the metadata hash as the second argument if a given proc expects 2 args" do
          passed_metadata = nil
          example_metadata.apply_condition(:if, lambda { |v, m| passed_metadata = m })
          passed_metadata.should == example_metadata
        end
      end

      describe "#for_example" do
        let(:metadata)           { Metadata.new.process("group description") }
        let(:mfe)                { metadata.for_example("example description", {:arbitrary => :options}) }
        let(:line_number)        { __LINE__ - 1 }

        it "stores the description" do
          mfe[:description].should == "example description"
        end

        it "stores the full_description (group description + example description)" do
          mfe[:full_description].should == "group description example description"
        end

        it "creates an empty execution result" do
          mfe[:execution_result].should == {}
        end

        it "extracts file path from caller" do
          mfe[:file_path].should == __FILE__
        end

        it "extracts line number from caller" do
          mfe[:line_number].should == line_number
        end

        it "extracts location from caller" do
          mfe[:location].should == "#{__FILE__}:#{line_number}"
        end

        it "uses :caller if passed as an option" do
          example_metadata = metadata.for_example('example description', {:caller => ['example_file:42']})
          example_metadata[:location].should == 'example_file:42'
        end

        it "merges arbitrary options" do
          mfe[:arbitrary].should == :options
        end

        it "points :example_group to the same hash object" do
          a = metadata.for_example("foo", {})[:example_group]
          b = metadata.for_example("bar", {})[:example_group]
          a[:description] = "new description"
          b[:description].should == "new description"
        end
      end

      describe ":describes" do
        context "with a String" do
          it "returns nil" do
            m = Metadata.new
            m.process('group')

            m = m.for_example("example", {})
            m[:example_group][:describes].should be_nil
          end
        end

        context "with a Symbol" do
          it "returns nil" do
            m = Metadata.new
            m.process(:group)

            m = m.for_example("example", {})
            m[:example_group][:describes].should be_nil
          end
        end

        context "with a class" do
          it "returns the class" do
            m = Metadata.new
            m.process(String)

            m = m.for_example("example", {})
            m[:example_group][:describes].should be(String)
          end
        end

        context "with describes from a superclass metadata" do
          it "returns the superclass' described class" do
            sm = Metadata.new
            sm.process(String)

            m = Metadata.new(sm)
            m.process(Array)

            m = m.for_example("example", {})
            m[:example_group][:describes].should be(String)
          end
        end
      end

      describe ":description" do
        it "just has the example description" do
          m = Metadata.new
          m.process('group')

          m = m.for_example("example", {})
          m[:description].should == "example"
        end

        context "with a string" do
          it "provides the submitted description" do
            m = Metadata.new
            m.process('group')

            m[:example_group][:description].should == "group"
          end
        end

        context "with a non-string" do
          it "provides the submitted description" do
            m = Metadata.new
            m.process('group')

            m[:example_group][:description].should == "group"
          end
        end

        context "with a non-string and a string" do
          it "concats the args" do
            m = Metadata.new
            m.process(Object, 'group')

            m[:example_group][:description].should == "Object group"
          end
        end
      end

      describe ":full_description" do
        it "concats example group name and description" do
          group_metadata = Metadata.new
          group_metadata.process('group')

          example_metadata = group_metadata.for_example("example", {})
          example_metadata[:full_description].should == "group example"
        end

        it "concats nested example group descriptions" do
          parent = Metadata.new
          parent.process(Object, 'parent')

          child = Metadata.new(parent)
          child.process('child')

          child[:example_group][:full_description].should == "Object parent child"
        end

        %w[# . ::].each do |char|
          context "with a 2nd arg starting with #{char}" do
          it "removes the space" do
            m = Metadata.new
            m.process(Array, "#{char}method")
            m[:example_group][:full_description].should eq("Array#{char}method")
          end
          end
        end

        %w[# . ::].each do |char|
          context "with a nested description starting with #{char}" do
            it "removes the space" do
              parent = Metadata.new
              parent.process("Object")
              child = Metadata.new(parent)
              child.process("#{char}method")
              child[:example_group][:full_description].should eq("Object#{char}method")
            end
          end
        end
      end

      describe ":file_path" do
        it "finds the first non-rspec lib file in the caller array" do
          m = Metadata.new
          m.process(:caller => [
                    "./lib/rspec/core/foo.rb",
                    "#{__FILE__}:#{__LINE__}"
          ])
          m[:example_group][:file_path].should == __FILE__
        end
      end

      describe ":line_number" do
        it "finds the line number with the first non-rspec lib file in the backtrace" do
          m = Metadata.new
          m.process({})
          m[:example_group][:line_number].should == __LINE__ - 1
        end

        it "finds the line number with the first spec file with drive letter" do
          m = Metadata.new
          m.process(:caller => [ "C:/path/to/file_spec.rb:#{__LINE__}" ])
          m[:example_group][:line_number].should == __LINE__ - 1
        end

        it "uses the number after the first : for ruby 1.9" do
          m = Metadata.new
          m.process(:caller => [ "#{__FILE__}:#{__LINE__}:999" ])
          m[:example_group][:line_number].should == __LINE__ - 1
        end
      end

      describe "child example group" do
        it "nests the parent's example group metadata" do
          parent = Metadata.new
          parent.process(Object, 'parent')

          child = Metadata.new(parent)
          child.process()

          child[:example_group][:example_group].should == parent[:example_group]
        end
      end
    end
  end
end

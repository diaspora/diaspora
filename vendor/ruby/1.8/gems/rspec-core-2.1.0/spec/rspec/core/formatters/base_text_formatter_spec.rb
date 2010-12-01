require 'spec_helper'
require 'rspec/core/formatters/base_text_formatter'

module RSpec::Core::Formatters

  describe BaseTextFormatter do
    let(:output) { StringIO.new }
    let(:formatter) { RSpec::Core::Formatters::BaseTextFormatter.new(output) }

    describe "#summary_line" do
      context "with 0s" do
        it "outputs pluralized (excluding pending)" do
          formatter.summary_line(0,0,0).should eq("0 examples, 0 failures")
        end
      end

      context "with 1s" do
        it "outputs singular (including pending)" do
          formatter.summary_line(1,1,1).should eq("1 example, 1 failure, 1 pending")
        end
      end

      context "with 2s" do
        it "outputs pluralized (including pending)" do
          formatter.summary_line(2,2,2).should eq("2 examples, 2 failures, 2 pending")
        end
      end
    end

    describe "#dump_failures" do
      let(:group) { RSpec::Core::ExampleGroup.describe("group name") }

      before { RSpec.configuration.stub(:color_enabled?) { false } }

      def run_all_and_dump_failures
        group.run(formatter)
        formatter.dump_failures
      end

      it "preserves formatting" do
        group.example("example name") { "this".should eq("that") }

        run_all_and_dump_failures

        output.string.should =~ /group name example name/m
        output.string.should =~ /(\s+)expected \"that\"\n\1     got \"this\"/m
      end

      context 'for #share_examples_for' do
        it 'outputs the name and location' do

          share_examples_for 'foo bar' do
            it("example name") { "this".should eq("that") }
          end

          line = __LINE__.next
          group.it_should_behave_like('foo bar')

          run_all_and_dump_failures

          output.string.should include(
            'Shared Example Group: "foo bar" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end

        context 'that contains nested example groups' do
          it 'outputs the name and location' do
            share_examples_for 'foo bar' do
              describe 'nested group' do
                it("example name") { "this".should eq("that") }
              end
            end

            line = __LINE__.next
            group.it_should_behave_like('foo bar')

            run_all_and_dump_failures

            output.string.should include(
              'Shared Example Group: "foo bar" called from ' +
                "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
            )
          end
        end
      end

      context 'for #share_as' do
        it 'outputs the name and location' do

          share_as :FooBar do
            it("example name") { "this".should eq("that") }
          end

          line = __LINE__.next
          group.send(:include, FooBar)

          run_all_and_dump_failures

          output.string.should include(
            'Shared Example Group: "FooBar" called from ' +
              "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
          )
        end

        context 'that contains nested example groups' do
          it 'outputs the name and location' do

            share_as :NestedFoo do
              describe 'nested group' do
                describe 'hell' do
                  it("example name") { "this".should eq("that") }
                end
              end
            end

            line = __LINE__.next
            group.send(:include, NestedFoo)

            run_all_and_dump_failures

            output.string.should include(
              'Shared Example Group: "NestedFoo" called from ' +
                "./spec/rspec/core/formatters/base_text_formatter_spec.rb:#{line}"
            )
          end
        end
      end
    end

    describe "#dump_profile" do
      before do
        formatter.stub(:examples) do
          group = RSpec::Core::ExampleGroup.describe("group") do
            example("example")
          end
          group.run(double('reporter').as_null_object)
          group.examples
        end
      end

      it "names the example" do
        formatter.dump_profile
        output.string.should =~ /group example/m
      end

      it "prints the time" do
        formatter.dump_profile
        output.string.should =~ /0(\.\d+)? seconds/
      end

      it "prints the path" do
        formatter.dump_profile
        filename = __FILE__.split(File::SEPARATOR).last

        output.string.should =~ /#{filename}\:135/
      end
    end
  end
end

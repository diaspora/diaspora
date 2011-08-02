require 'spec_helper'

module RSpec::Core

  describe Subject do
    before(:each) { RSpec.configuration.configure_expectation_framework }

    describe "implicit subject" do
      describe "with a class" do
        it "returns an instance of the class" do
          ExampleGroup.describe(Array).subject.call.should == []
        end
      end

      describe "with a Module" do
        it "returns the Module" do
          ExampleGroup.describe(Enumerable).subject.call.should == Enumerable
        end
      end

      describe "with a string" do
        it "return the string" do
          ExampleGroup.describe("Foo").subject.call.should == 'Foo'
        end
      end

      describe "with a number" do
        it "returns the number" do
          ExampleGroup.describe(15).subject.call.should == 15
        end
      end

    end

    describe "explicit subject" do
      [false, nil].each do |falsy_value|
        context "with a value of #{falsy_value.inspect}" do
          it "is evaluated once per example" do
            group = ExampleGroup.describe(Array)
            group.before do
              Object.should_receive(:this_question?).once.and_return(falsy_value)
            end
            group.subject do
              Object.this_question?
            end
            group.example do
              subject
              subject
            end
            group.run.should be_true, "expected subject block to be evaluated only once"
          end
        end
      end

      describe "defined in a top level group" do
        it "replaces the implicit subject in that group" do
          group = ExampleGroup.describe(Array)
          group.subject { [1,2,3] }
          group.subject.call.should == [1,2,3]
        end
      end

      describe "defined in a top level group" do
        let(:group) do
          ExampleGroup.describe do
            subject{ [4,5,6] }
          end
        end

        it "is available in a nested group (subclass)" do
          nested_group = group.describe("I'm nested!") { }
          nested_group.subject.call.should == [4,5,6]
        end

        it "is available in a doubly nested group (subclass)" do
          nested_group = group.describe("Nesting level 1") { }
          doubly_nested_group = nested_group.describe("Nesting level 2") { }
          doubly_nested_group.subject.call.should == [4,5,6]
        end
      end
    end

    context "using 'self' as an explicit subject" do
      it "delegates matcher to the ExampleGroup" do
        group = ExampleGroup.describe("group") do
          subject { self }
          def ok?; true; end

          it { should eq(self) }
          it { should be_ok }
        end

        group.run.should be_true
      end
    end

    describe "#its" do
      subject do
        Class.new do
          def initialize
            @call_count = 0
          end

          def call_count
            @call_count += 1
          end
        end.new
      end

      context "with a call counter" do
        its(:call_count) { should eq(1) }
      end

      context "with nil value" do
        subject do
          Class.new do
            def nil_value
              nil
            end
          end.new
        end
        its(:nil_value) { should be_nil }
      end

      context "with nested attributes" do
        subject do
          Class.new do
            def name
              "John"
            end
          end.new
        end
        its("name")            { should eq("John") }
        its("name.size")       { should eq(4) }
        its("name.size.class") { should eq(Fixnum) }
      end

      context "when it responds to #[]" do
        subject do
          Class.new do
            def [](*objects)
              objects.map do |object|
                "#{object.class}: #{object.to_s}"
              end.join("; ")
            end

            def name
              "George"
            end
          end.new
        end
        its([:a]) { should == 'Symbol: a' }
        its(['a']) { should == 'String: a' }
        its([:b, 'c', 4]) { should == 'Symbol: b; String: c; Fixnum: 4' }
        its(:name) { should = "George" }
        context "when referring to an attribute without the proper array syntax" do
          context "it raises an error" do
            its(:age) do
              expect do
                should eq(64)
              end.to raise_error(NoMethodError)
            end
          end
        end
      end

      context "when it does not respond to #[]" do
        subject { Object.new }

        context "it raises an error" do
          its([:a]) do
            expect do
              should == 'Symbol: a'
            end.to raise_error(NoMethodError)
          end
        end
      end

      context "calling and overriding super" do
        it "calls to the subject defined in the parent group" do
          group = ExampleGroup.describe(Array) do
            subject { [1, 'a'] }

            its(:last) { should == 'a' }

            describe '.first' do
              def subject; super().first; end

              its(:next) { should == 2 }
            end
          end

          group.run.should be_true
        end
      end

    end
  end
end

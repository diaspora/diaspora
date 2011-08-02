Feature: double handling to_ary

  Ruby implicitly sends to_ary to any objects in an Array when the array
  receives `flatten`:

      [obj].flatten # => obj.to_ary

  To support this, an RSpec double will raise a NoMethodError when it receives
  `to_ary`, unless that method is explicitly stubbed.

  Scenario: double receiving to_ary
    Given a file named "example.rb" with:
      """
      describe "a double receiving to_ary" do
        shared_examples "to_ary" do
          it "returns nil" do
            expect do
              obj.to_ary.should be_nil
            end.to raise_error(NoMethodError)
          end

          it "can be overridden with a stub" do
            obj.stub(:to_ary) { :non_nil_value }
            obj.to_ary.should be(:non_nil_value)
          end

          it "supports Array#flatten" do
            obj = double('foo')
            [obj].flatten.should eq([obj])
          end
        end

        context "double as_null_object" do
          let(:obj) { double('obj').as_null_object }
          include_examples "to_ary"
        end

        context "double without as_null_object" do
          let(:obj) { double('obj') }
          include_examples "to_ary"
        end
      end
     """
    When I run `rspec example.rb`
    Then the examples should all pass

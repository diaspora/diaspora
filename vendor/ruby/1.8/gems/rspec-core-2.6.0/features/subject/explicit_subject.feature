Feature: explicit subject

  Use subject() in the group scope to explicitly define the value that is
  returned by the subject() method in the example scope.

  Scenario: subject in top level group
    Given a file named "top_level_subject_spec.rb" with:
      """
      describe Array, "with some elements" do
        subject { [1,2,3] }
        it "should have the prescribed elements" do
          subject.should == [1,2,3]
        end
      end
      """
    When I run `rspec top_level_subject_spec.rb`
    Then the examples should all pass

  Scenario: subject in a nested group
    Given a file named "nested_subject_spec.rb" with:
      """
      describe Array do
        subject { [1,2,3] }
        describe "with some elements" do
          it "should have the prescribed elements" do
            subject.should == [1,2,3]
          end
        end
      end
      """
    When I run `rspec nested_subject_spec.rb`
    Then the examples should all pass

  Scenario: access subject from before block
    Given a file named "top_level_subject_spec.rb" with:
      """
      describe Array, "with some elements" do
        subject { [] }
        before { subject.push(1,2,3) }
        it "should have the prescribed elements" do
          subject.should == [1,2,3]
        end
      end
      """
    When I run `rspec top_level_subject_spec.rb`
    Then the examples should all pass

  Scenario: invoke helper method from subject block
    Given a file named "helper_subject_spec.rb" with:
      """
      describe Array do
        def prepared_array; [1,2,3] end
        subject { prepared_array }
        describe "with some elements" do
          it "should have the prescribed elements" do
            subject.should == [1,2,3]
          end
        end
      end
      """
    When I run `rspec helper_subject_spec.rb`
    Then the examples should all pass

  Scenario: subject block is invoked at most once per example
    Given a file named "nil_subject_spec.rb" with:
      """
      describe Array do
        describe "#[]" do
          context "with index out of bounds" do
            before { Array.should_receive(:one_two_three).once.and_return([1,2,3]) }
            subject { Array.one_two_three[42] }
            it { should be_nil }
          end
        end
      end
      """
    When I run `rspec nil_subject_spec.rb`
    Then the examples should all pass

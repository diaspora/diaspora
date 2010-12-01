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
    When I run "rspec top_level_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"

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
    When I run "rspec nested_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"

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
    When I run "rspec top_level_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"

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
    When I run "rspec helper_subject_spec.rb"
    Then the output should contain "1 example, 0 failures"

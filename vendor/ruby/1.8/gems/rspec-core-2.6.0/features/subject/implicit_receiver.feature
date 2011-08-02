Feature: implicit receiver

  When should() is called in an example without an explicit receiver, it is
  invoked against the subject (explicit or implicit).

  Scenario: implicit subject
    Given a file named "example_spec.rb" with:
      """
      describe Array do
        describe "when first created" do
          it { should be_empty }
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

  Scenario: explicit subject
    Given a file named "example_spec.rb" with:
      """
      describe Array do
        describe "with 3 items" do
          subject { [1,2,3] }
          it { should_not be_empty }
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass

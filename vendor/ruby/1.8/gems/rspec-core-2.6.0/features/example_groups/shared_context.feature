Feature: shared context

  Use `shared_context` to define a block that will be evaluated in the context
  of example groups either explicitly, using `include_context`, or implicitly by
  matching metdata.

  Background:
    Given a file named "shared_stuff.rb" with:
      """
      shared_context "shared stuff", :a => :b do
        before { @some_var = :some_value }
        def shared_method
          "it works"
        end
        let(:shared_let) { {'arbitrary' => 'object'} }
        subject do
          'this is the subject'
        end
      end
      """
  
  Scenario: declare shared context and include it with include_context
    Given a file named "shared_context_example.rb" with:
      """
      require "./shared_stuff.rb"

      describe "group that includes a shared context using 'include_context'" do
        include_context "shared stuff"

        it "has access to methods defined in shared context" do
          shared_method.should eq("it works")
        end

        it "has access to methods defined with let in shared context" do
          shared_let['arbitrary'].should eq('object')
        end

        it "runs the before hooks defined in the shared context" do
          @some_var.should be(:some_value)
        end

        it "accesses the subject defined in the shared context" do
          subject.should eq('this is the subject')
        end
      end
      """
    When I run `rspec shared_context_example.rb`
    Then the examples should all pass

  Scenario: declare shared context and include it with metadata
    Given a file named "shared_context_example.rb" with:
      """
      require "./shared_stuff.rb"

      describe "group that includes a shared context using metadata", :a => :b do
        it "has access to methods defined in shared context" do
          shared_method.should eq("it works")
        end

        it "has access to methods defined with let in shared context" do
          shared_let['arbitrary'].should eq('object')
        end

        it "runs the before hooks defined in the shared context" do
          @some_var.should be(:some_value)
        end

        it "accesses the subject defined in the shared context" do
          subject.should eq('this is the subject')
        end
      end
      """
    When I run `rspec shared_context_example.rb`
    Then the examples should all pass

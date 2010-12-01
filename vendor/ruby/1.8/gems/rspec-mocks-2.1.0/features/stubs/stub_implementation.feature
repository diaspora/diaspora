Feature: Stub with substitute implementation

  You can stub an implementation of a method (a.k.a. fake) by passing a block
  to the stub() method.
  
  Scenario: stub implementation
    Given a file named "stub_implementation_spec.rb" with:
      """
      describe "a stubbed implementation" do
        it "works" do
          object = Object.new
          object.stub(:foo) do |arg|
            if arg == :this
              "got this"
            elsif arg == :that
              "got that"
            end
          end
          
          object.foo(:this).should eq("got this")
          object.foo(:that).should eq("got that")
        end
      end
      """
    When I run "rspec ./stub_implementation_spec.rb"
    Then the output should contain "1 example, 0 failures"

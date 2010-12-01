Feature: specify types of objects

  rspec-expectations includes two matchers to specify types of objects:

    * obj.should be_kind_of(type): calls obj.kind_of?(type), which returns
      true if type is in obj's class hierarchy or is a module and is
      included in a class in obj's class hierarchy.
    * obj.should be_instance_of(type): calls obj.instance_of?(type), which
      returns true if and only if type if obj's class.

  Both of these matchers have aliases:

    * obj.should be_a_kind_of(type) # same as obj.should be_kind_of(type)
    * obj.should be_a(type) # same as obj.should be_kind_of(type)
    * obj.should be_an(type) # same as obj.should be_kind_of(type)
    * obj.should be_an_instance_of(type) # same as obj.should be_instance_of(type)

  Scenario: be_(a_)kind_of matcher
    Given a file named "be_kind_of_matcher_spec.rb" with:
      """
      module MyModule; end

      class Fixnum
        include MyModule
      end

      describe 17 do
        # the actual class
        it { should be_kind_of(Fixnum) }
        it { should be_a_kind_of(Fixnum) }
        it { should be_a(Fixnum) }

        # the superclass
        it { should be_kind_of(Integer) }
        it { should be_a_kind_of(Integer) }
        it { should be_an(Integer) }

        # an included module
        it { should be_kind_of(MyModule) }
        it { should be_a_kind_of(MyModule) }
        it { should be_a(MyModule) }

        # negative passing case
        it { should_not be_kind_of(String) }
        it { should_not be_a_kind_of(String) }
        it { should_not be_a(String) }

        # deliberate failures
        it { should_not be_kind_of(Fixnum) }
        it { should_not be_a_kind_of(Fixnum) }
        it { should_not be_a(Fixnum) }
        it { should_not be_kind_of(Integer) }
        it { should_not be_a_kind_of(Integer) }
        it { should_not be_an(Integer) }
        it { should_not be_kind_of(MyModule) }
        it { should_not be_a_kind_of(MyModule) }
        it { should_not be_a(MyModule) }
        it { should be_kind_of(String) }
        it { should be_a_kind_of(String) }
        it { should be_a(String) }
      end
      """
    When I run "rspec be_kind_of_matcher_spec.rb"
    Then the output should contain all of these:
      | 24 examples, 12 failures                 |
      | expected 17 not to be a kind of Fixnum   |
      | expected 17 not to be a kind of Integer  |
      | expected 17 not to be a kind of MyModule |
      | expected 17 to be a kind of String       |

  Scenario: be_(an_)instance_of matcher
    Given a file named "be_instance_of_matcher_spec.rb" with:
      """
      module MyModule; end

      class Fixnum
        include MyModule
      end

      describe 17 do
        # the actual class
        it { should be_instance_of(Fixnum) }
        it { should be_an_instance_of(Fixnum) }

        # the superclass
        it { should_not be_instance_of(Integer) }
        it { should_not be_an_instance_of(Integer) }

        # an included module
        it { should_not be_instance_of(MyModule) }
        it { should_not be_an_instance_of(MyModule) }

        # another class with no relation to the subject's hierarchy
        it { should_not be_instance_of(String) }
        it { should_not be_an_instance_of(String) }

        # deliberate failures
        it { should_not be_instance_of(Fixnum) }
        it { should_not be_an_instance_of(Fixnum) }
        it { should be_instance_of(Integer) }
        it { should be_an_instance_of(Integer) }
        it { should be_instance_of(MyModule) }
        it { should be_an_instance_of(MyModule) }
        it { should be_instance_of(String) }
        it { should be_an_instance_of(String) }
      end
      """
    When I run "rspec be_instance_of_matcher_spec.rb"
    Then the output should contain all of these:
      | 16 examples, 8 failures                     |
      | expected 17 not to be an instance of Fixnum |
      | expected 17 to be an instance of Integer    |
      | expected 17 to be an instance of MyModule   |
      | expected 17 to be an instance of String     |

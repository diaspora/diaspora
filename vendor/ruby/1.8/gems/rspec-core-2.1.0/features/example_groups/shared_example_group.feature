Feature: Shared example group

  Shared example groups let you describe behaviour of types or modules. When
  declared, a shared group's content is stored. It is only realized in the
  context of another example group, which provides any context the shared group
  needs to run.

  A shared group is included in another group using the it_behaves_like() or
  it_should_behave_like() methods.

  Scenario: shared example group applied to two groups
    Given a file named "collection_spec.rb" with:
    """
    require "set"

    shared_examples_for "a collection" do
      let(:collection) { described_class.new([7, 2, 4]) }

      context "initialized with 3 items" do
        it "says it has three items" do
          collection.size.should eq(3)
        end
      end

      describe "#include?" do
        context "with an an item that is in the collection" do
          it "returns true" do
            collection.include?(7).should be_true
          end
        end

        context "with an an item that is not in the collection" do
          it "returns false" do
            collection.include?(9).should be_false
          end
        end
      end
    end

    describe Array do
      it_behaves_like "a collection"
    end

    describe Set do
      it_behaves_like "a collection"
    end
    """
    When I run "rspec collection_spec.rb --format documentation"
    Then the output should contain "6 examples, 0 failures"
    And the output should contain:
      """
      Array
        behaves like a collection
          initialized with 3 items
            says it has three items
          #include?
            with an an item that is in the collection
              returns true
            with an an item that is not in the collection
              returns false

      Set
        behaves like a collection
          initialized with 3 items
            says it has three items
          #include?
            with an an item that is in the collection
              returns true
            with an an item that is not in the collection
              returns false
      """

  Scenario: Providing context to a shared group using a block
    Given a file named "shared_example_group_spec.rb" with:
    """
    require "set"

    shared_examples_for "a collection object" do
      describe "<<" do
        it "adds objects to the end of the collection" do
          collection << 1
          collection << 2
          collection.to_a.should eq([1,2])
        end
      end
    end

    describe Array do
      it_should_behave_like "a collection object" do
        let(:collection) { Array.new }
      end
    end

    describe Set do
      it_should_behave_like "a collection object" do
        let(:collection) { Set.new }
      end
    end
    """
    When I run "rspec shared_example_group_spec.rb --format documentation"
    Then the output should contain "2 examples, 0 failures"
    And the output should contain:
      """
      Array
        it should behave like a collection object
          <<
            adds objects to the end of the collection

      Set
        it should behave like a collection object
          <<
            adds objects to the end of the collection
      """

  Scenario: Passing parameters to a shared example group
    Given a file named "shared_example_group_params_spec.rb" with:
    """
    shared_examples_for "a measurable object" do |measurement, measurement_methods|
      measurement_methods.each do |measurement_method|
        it "should return #{measurement} from ##{measurement_method}" do
          subject.send(measurement_method).should == measurement
        end
      end
    end

    describe Array, "with 3 items" do
      subject { [1, 2, 3] }
      it_should_behave_like "a measurable object", 3, [:size, :length]
    end

    describe String, "of 6 characters" do
      subject { "FooBar" }
      it_should_behave_like "a measurable object", 6, [:size, :length]
    end
    """
    When I run "rspec shared_example_group_params_spec.rb --format documentation"
    Then the output should contain "4 examples, 0 failures"
    And the output should contain:
      """
      Array with 3 items
        it should behave like a measurable object
          should return 3 from #size
          should return 3 from #length

      String of 6 characters
        it should behave like a measurable object
          should return 6 from #size
          should return 6 from #length
      """

  Scenario: Aliasing "it_should_behave_like" to "it_has_behavior"
    Given a file named "shared_example_group_spec.rb" with:
      """
      RSpec.configure do |c|
        c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
      end

      shared_examples_for 'sortability' do
        it 'responds to <=>' do
          sortable.should respond_to(:<=>)
        end
      end

      describe String do
        it_has_behavior 'sortability' do
          let(:sortable) { 'sample string' }
        end
      end
      """
    When I run "rspec shared_example_group_spec.rb --format documentation"
    Then the output should contain "1 example, 0 failures"
    And the output should contain:
      """
      String
        has behavior: sortability
          responds to <=>
      """

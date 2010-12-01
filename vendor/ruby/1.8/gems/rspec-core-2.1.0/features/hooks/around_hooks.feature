Feature: around hooks

  Around hooks receive the example as a block argument, extended to behave like
  a proc.  This lets you define code that should be executed before and after
  the example. Of course, you can do the same thing with before and after hooks,
  and it's often cleaner to do so.

  Where around hooks shine is when you want to run an example in a block. For
  example, if your database library offers a transaction method that receives
  a block, you can use an around hook as described in the first scenario:

  Scenario: use the example as a block within the block passed to around()
    Given a file named "example_spec.rb" with:
      """
      class Database
        def self.transaction
          puts "open transaction"
          yield
          puts "close transaction"
        end
      end

      describe "around filter" do
        around(:each) do |example|
          Database.transaction(&example)
        end

        it "gets run in order" do
          puts "run the example"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain:
      """
      open transaction
      run the example
      close transaction
      """

  Scenario: invoke the example using run()
    Given a file named "example_spec.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain:
      """
      around each before
      in the example
      around each after
      """

  Scenario: define a global around hook
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |c|
        c.around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end
      end

      describe "around filter" do
        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain:
      """
      around each before
      in the example
      around each after
      """

  Scenario: before/after(:each) hooks are wrapped by the around hook
    Given a file named "example_spec.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        before(:each) do
          puts "before each"
        end

        after(:each) do
          puts "after each"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain:
      """
      around each before
      before each
      in the example
      after each
      around each after
      """

  Scenario: before/after(:all) hooks are NOT wrapped by the around hook
    Given a file named "example_spec.rb" with:
      """
      describe "around filter" do
        around(:each) do |example|
          puts "around each before"
          example.run
          puts "around each after"
        end

        before(:all) do
          puts "before all"
        end

        after(:all) do
          puts "after all"
        end

        it "gets run in order" do
          puts "in the example"
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain:
      """
      before all
      around each before
      in the example
      around each after
      .after all
      """

  Scenario: examples run by an around block are run in the configured context
    Given a file named "example_spec.rb" with:
      """
      module IncludedInConfigureBlock
        def included_in_configure_block; true; end
      end

      Rspec.configure do |c|
        c.include IncludedInConfigureBlock
      end

      describe "around filter" do
        around(:each) do |example|
          example.run
        end

        it "runs the example in the correct context" do
          included_in_configure_block.should be_true
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failure"

  Scenario: implicitly pending examples are detected as Not Yet Implemented
    Given a file named "example_spec.rb" with:
      """
      describe "implicit pending example" do
        around(:each) do |example|
          example.run
        end

        it "should be detected as Not Yet Implemented"
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        implicit pending example should be detected as Not Yet Implemented
          # Not Yet Implemented
      """


  Scenario: explicitly pending examples are detected as pending
    Given a file named "example_spec.rb" with:
      """
      describe "explicit pending example" do
        around(:each) do |example|
          example.run
        end

        it "should be detected as pending" do
          pending
        end
      end
      """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
        explicit pending example should be detected as pending
          # No reason given
      """

  Scenario: multiple around hooks in the same scope
    Given a file named "example_spec.rb" with:
    """
    describe "if there are multiple around hooks in the same scope" do
      around(:each) do |example|
        puts "first around hook before"
        example.run
        puts "first around hook after"
      end

      around(:each) do |example|
        puts "second around hook before"
        example.run
        puts "second around hook after"
      end

      it "they should all be run" do
        puts "in the example"
        1.should == 1
      end
    end
    """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failure"
    And the output should contain:
    """
    first around hook before
    second around hook before
    in the example
    second around hook after
    first around hook after
    """

  Scenario: around hooks in multiple scopes
    Given a file named "example_spec.rb" with:
    """
    describe "if there are around hooks in an outer scope" do
      around(:each) do |example|
        puts "first outermost around hook before"
        example.run
        puts "first outermost around hook after"
      end

      around(:each) do |example|
        puts "second outermost around hook before"
        example.run
        puts "second outermost around hook after"
      end

      describe "outer scope" do
        around(:each) do |example|
          puts "first outer around hook before"
          example.run
          puts "first outer around hook after"
        end

        around(:each) do |example|
          puts "second outer around hook before"
          example.run
          puts "second outer around hook after"
        end

        describe "inner scope" do
          around(:each) do |example|
            puts "first inner around hook before"
            example.run
            puts "first inner around hook after"
          end

          around(:each) do |example|
            puts "second inner around hook before"
            example.run
            puts "second inner around hook after"
          end

          it "they should all be run" do
            puts "in the example"
          end
        end
      end
    end
    """
    When I run "rspec example_spec.rb"
    Then the output should contain "1 example, 0 failure"
    And the output should contain:
    """
    first outermost around hook before
    second outermost around hook before
    first outer around hook before
    second outer around hook before
    first inner around hook before
    second inner around hook before
    in the example
    second inner around hook after
    first inner around hook after
    second outer around hook after
    first outer around hook after
    second outermost around hook after
    first outermost around hook after
    """

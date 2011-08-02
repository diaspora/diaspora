Feature: mock with rspec

  RSpec uses its own mocking framework by default, or you can configure it
  explicitly.

  Scenario: passing message expectation
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "mocking with RSpec" do
        it "passes when it should" do
          receiver = double('receiver')
          receiver.should_receive(:message)
          receiver.message
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass 

  Scenario: failing message expecation
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "mocking with RSpec" do
        it "fails when it should" do
          receiver = double('receiver')
          receiver.should_receive(:message)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "1 example, 1 failure"

  Scenario: failing message expectation in pending block (remains pending)
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "failed message expectation in a pending block" do
        it "is listed as pending" do
          pending do
            receiver = double('receiver')
            receiver.should_receive(:message)
          end
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "1 example, 0 failures, 1 pending"
    And the exit status should be 0

  Scenario: passing message expectation in pending block (fails)
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "passing message expectation in a pending block" do
        it "fails with FIXED" do
          pending do
            receiver = double('receiver')
            receiver.should_receive(:message)
            receiver.message
          end
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the output should contain "FIXED"
    Then the output should contain "1 example, 1 failure"
    And the exit status should be 1

  Scenario: accessing RSpec.configuration.mock_framework.framework_name 
    Given a file named "example_spec.rb" with:
      """
      RSpec.configure do |config|
        config.mock_framework = :rspec
      end

      describe "RSpec.configuration.mock_framework.framework_name" do
        it "returns :rspec" do
          RSpec.configuration.mock_framework.framework_name.should eq(:rspec)
        end
      end
      """
    When I run `rspec example_spec.rb`
    Then the examples should all pass 

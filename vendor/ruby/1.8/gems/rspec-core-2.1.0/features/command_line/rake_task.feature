Feature: rake task
  
  RSpec ships with a rake task with a number of useful options

  Scenario: default options with passing spec (prints command and exit status is 0)
    Given a file named "Rakefile" with:
      """
      require 'rspec/core/rake_task'

      RSpec::Core::RakeTask.new(:spec)

      task :default => :spec
      """
    And a file named "spec/thing_spec.rb" with:
      """
      describe "something" do
        it "does something" do
          # pass
        end
      end
      """
    When I run "rake"
    Then the stderr should contain "ruby -S rspec"
    Then the exit status should be 0

  Scenario: default options with failing spec (exit status is 1)
    Given a file named "Rakefile" with:
      """
      require 'rspec/core/rake_task'

      RSpec::Core::RakeTask.new(:spec)

      task :default => :spec
      """
    And a file named "spec/thing_spec.rb" with:
      """
      describe "something" do
        it "does something" do
          fail
        end
      end
      """
    When I run "rake"
    Then the exit status should be 1
      
  Scenario: fail_on_error = false with failing spec (exit status is 0)
    Given a file named "Rakefile" with:
      """
      require 'rspec/core/rake_task'

      RSpec::Core::RakeTask.new(:spec) do |t|
        t.fail_on_error = false
      end

      task :default => :spec
      """
    And a file named "spec/thing_spec.rb" with:
      """
      describe "something" do
        it "does something" do
          fail
        end
      end
      """
    When I run "rake"
    Then the exit status should be 0
      


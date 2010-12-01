Feature: read command line configuration options from files

  RSpec reads command line configuration options from files in two different
  locations:
  
    Local:  "./.rspec" (i.e. in the project's root directory)
    Global: "~/.rspec" (i.e. in the user's home directory)

  Options declared in the local file override those in the global file, while
  those declared in RSpec.configure will override any ".rspec" file.
  
  Scenario: color set in .rspec
    Given a file named ".rspec" with:
      """
      --color
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "color_enabled" do
        context "when set with RSpec.configure" do
          before do
            # color is disabled for non-tty output, so stub the output stream
            # to say it is tty, even though we're running this with cucumber
            RSpec.configuration.output_stream.stub(:tty?) { true }
          end

          it "is true" do
            RSpec.configuration.should be_color_enabled
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: formatter set in RSpec.configure overrides .rspec
    Given a file named ".rspec" with:
      """
      --format progress
      """
    And a file named "spec/spec_helper.rb" with:
      """
      RSpec.configure {|c| c.formatter = 'documentation'}
      """
    And a file named "spec/example_spec.rb" with:
      """
      require "spec_helper"

      describe "formatter" do
        context "when set with RSpec.configure and in spec.opts" do
          it "takes the value set in spec.opts" do
            RSpec.configuration.formatter.should be_an(RSpec::Core::Formatters::DocumentationFormatter)
          end
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"
    
  Scenario: using ERB in .rspec
    Given a file named ".rspec" with:
      """
      --format <%= true ? 'documentation' : 'progress' %>
      """
    And a file named "spec/example_spec.rb" with:
      """
      describe "formatter" do
        it "is set to documentation" do
          RSpec.configuration.formatter.should be_an(RSpec::Core::Formatters::DocumentationFormatter)
        end
      end
      """
    When I run "rspec ./spec/example_spec.rb"
    Then the output should contain "1 example, 0 failures"

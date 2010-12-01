Feature: URL helpers in mailer examples

  Scenario: using URL helpers with default options
    Given a file named "config/initializers/mailer_defaults.rb" with:
      """
      Rails.configuration.action_mailer.default_url_options = { :host => 'example.com' }
      """
    And a file named "spec/mailers/notifications_spec.rb" with:
      """
      require 'spec_helper'

      describe Notifications do
        it 'should have access to URL helpers' do
          lambda { gadgets_url }.should_not raise_error
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "1 example, 0 failures"

  Scenario: using URL helpers without default options
    Given a file named "config/initializers/mailer_defaults.rb" with:
      """
      # no default options
      """
    And a file named "spec/mailers/notifications_spec.rb" with:
      """
      require 'spec_helper'

      describe Notifications do
        it 'should have access to URL helpers' do
          lambda { gadgets_url :host => 'example.com' }.should_not raise_error
          lambda { gadgets_url }.should raise_error
        end
      end
      """
    When I run "rspec spec"
    Then the output should contain "1 example, 0 failures"

Given /^I symlink "([^"]*)" to "([^"]*)"$/ do |source, target|
  source = File.expand_path(source, __FILE__)
  in_current_dir do
    target = File.expand_path(target)
    FileUtils.ln_s(source, target)
  end
end

Given /^I have created a new Rails 3 app "([^"]*)" with cucumber\-rails support$/ do |app_name|
  steps %Q{
    Given I am using rvm "ruby-1.8.7-p249"
    And I am using rvm gemset "cucumber-rails-3.0.0.beta-gemset-1" with Gemfile:
      """
      gem 'rails', '3.0.0.beta'
      gem 'sqlite3-ruby', '1.2.5'
      gem 'capybara', '0.3.8'
      """
    When I successfully run "rails rails-3-app"
    Then it should pass with:
      """
      README
      """
    And I cd to "#{app_name}"
    And I symlink "../../.." to "vendor/plugins/cucumber-rails"
    And I append to "Gemfile" with:
      """
      gem 'capybara', '0.3.8'
      gem 'cucumber', :path => '../../../../cucumber'

      """
    And I successfully run "rails generate cucumber:install --capybara"
    And I successfully run "bundle lock"
    And I successfully run "rake db:migrate"
  }
end

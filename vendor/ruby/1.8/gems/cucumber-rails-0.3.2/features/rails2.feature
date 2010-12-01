Feature: Rails 2
  In order to take over the world
  Cucumber-Rails should work on major versions
  of Rails2 and Ruby, with Capybara, Webrat, Spork and DatabaseCleaner

  @announce @puts
  Scenario Outline: Run Cucumber
    Given I am using rvm "<ruby_version>"
    And I am using rvm gemset "cucumber-rails-<rails_version>" with Gemfile:
      """
      source :gemcutter
      gem 'rails', '<rails_version>'
      gem 'sqlite3-ruby', '1.2.5'
      gem 'capybara', '0.3.8'
      gem 'webrat', '0.7.1'
      gem 'rspec-rails', '1.3.2'
      #gem 'cucumber', '0.8.0'
      gem 'cucumber', :path => '../../../cucumber'
      gem 'database_cleaner', '0.5.2'
      gem 'culerity', '0.2.10'
      gem 'celerity', '0.7.9'
      """
    And I successfully run "rails rails-2-app"
    And I cd to "rails-2-app"
    And I symlink "../../../../cucumber" to "vendor/plugins/cucumber"
    And I symlink "../../.." to "vendor/plugins/cucumber-rails"
    And I successfully run "ruby script/generate cucumber --capybara"
    And I successfully run "ruby script/generate feature post title:string body:text published:boolean <feature_args>"
    And I successfully run "ruby script/generate scaffold post title:string body:text published:boolean"
    And I successfully run "ruby script/generate scaffold cukes name:string"
    And I write to "app/controllers/cukes_controller.rb" with:
      """
      class CukesController < ApplicationController
        def index
          redirect_to cuke_path(10, :params => {:name => 'cucumber', :what => 'vegetable'})
        end

        def show
          render :text => "Cuke #{params[:id]}"
        end
      end
      """
    And I write to "features/tests.feature" with:
      """
      Feature: Tests
        Scenario: Tests
          When I go to the cukes page
          Then I should have the following query string: 
            |name|cucumber|
            |what|vegetable|
          And I should see "Cuke 10"
      """
    And I successfully run "rake db:migrate"
    When I successfully run "rake cucumber"
    Then it should pass with:
      """
      3 scenarios (3 passed)
      14 steps (14 passed)
      """

    Examples:
      | generator_args      | feature_args        | ruby_version | rails_version |
      | --webrat --testunit |                     | 1.8.6        | 2.3.5         |
      | --capybara --rspec  | --capybara culerity | 1.8.7        | 2.3.8         |

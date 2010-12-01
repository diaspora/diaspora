Feature: automatically load step definitions

  Scenario: generate a rails 3 application and use factory definitions
    When I generate a new rails application
    And I save the following as "Gemfile"
      """
      source "http://rubygems.org"
      gem 'rails', '3.0.0.beta4'
      gem 'sqlite3-ruby', :require => 'sqlite3'
      gem 'factory_girl_rails', :path => '../../'
      """
    When I run "bundle lock"
    And I save the following as "db/migrate/1_create_users.rb"
      """
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
      """
    When I run "rake db:migrate"
    And I save the following as "app/models/user.rb"
      """
      class User < ActiveRecord::Base
      end
      """
    When I save the following as "test/factories.rb"
      """
      Factory.define :user do |user|
        user.name 'Frank'
      end
      """
    When I save the following as "test/unit/user_test.rb"
      """
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        test "use factory" do
          user = Factory(:user)
          assert_equal 'Frank', user.name
        end
      end
      """
    When I run "rake test"
    Then I should see "1 tests, 1 assertions, 0 failures, 0 errors"

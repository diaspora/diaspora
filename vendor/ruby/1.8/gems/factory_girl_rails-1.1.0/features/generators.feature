Feature:
  In order to easily generate factory files instead of fixture files when generating models
  As a user of Rails3 and factory_girl
  I would like to use factory_girl_rails generators.

  Scenario: The factory_girl_rails generators create a factory file
  for each model that I generate
    When I successfully run `bundle exec rails new testapp`
    And I cd to "testapp"
    And I add "factory_girl_rails" from this project as a dependency
    When I successfully run `bundle install`
    And I successfully run `bundle exec rails generate model User name:string --fixture-replacement=factory_girl`
    Then the output should contain "test/factories/users.rb"
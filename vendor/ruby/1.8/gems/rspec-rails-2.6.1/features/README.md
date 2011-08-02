rspec-rails extends Rails' built-in testing framework to support rspec examples
for requests, controllers, models, views, helpers, mailers and routing.

## Rails-3

rspec-rails-2 supports rails-3.0.0 and later. For earlier versions of Rails,
you need [rspec-rails-1.3](http://rspec.info).

## Install

    gem install rspec-rails

This installs the following gems:

    rspec
    rspec-core
    rspec-expectations
    rspec-mocks
    rspec-rails

## Configure

Add rspec-rails to the :test and :development groups in the Gemfile:

    group :test, :development do
      gem "rspec-rails", "~> 2.4"
    end

It needs to be in the :development group to expose generators and rake tasks
without having to type RAILS_ENV=test.

Now you can run:

    script/rails generate rspec:install

This adds the spec directory and some skeleton files, including a .rspec
file.

## Webrat and Capybara

You can choose between webrat or capybara for simulating a browser, automating
a browser, or setting expectations using the matchers they supply. Just add
your preference to the Gemfile:

    gem "webrat"
    gem "capybara"

Note that Capybara matchers are not available in view or helper specs.

## Issues

The documentation for rspec-rails is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-rails/issues) or a [pull
request](http://github.com/rspec/rspec-rails).

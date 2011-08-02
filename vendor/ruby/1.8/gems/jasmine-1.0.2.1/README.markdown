# The Jasmine Gem

The [Jasmine](http://github.com/pivotal/jasmine) Ruby Gem is a package of helper code for developing Jasmine projects for Ruby-based web projects (Rails, Sinatra, etc.) or for JavaScript projects where Ruby is a welcome partner. It serves up a project's Jasmine suite in a browser so you can focus on your code instead of manually editing script tags in the Jasmine runner HTML file.

## Contents
This gem contains:

* A small server that builds and executes a Jasmine suite for a project
* A script that sets up a project to use the Jasmine gem's server
* Generators for Ruby on Rails projects (Rails 2 and Rails 3)

You can get all of this by: `gem install jasmine` or by adding Jasmine to your `Gemfile`.

## Init A Project

To initialize a project for Jasmine, it depends on your web framework

For Rails2 support, use

`script/generate jasmine`

For Rails3 support, use

`rails g jasmine:install`
`rails g jasmine:examples`

For any other project (Sinatra, Merb, or something we don't yet know about) use

`jasmine init`

## Usage

Start the Jasmine server:

`rake jasmine`

Point your browser to `localhost:8888`. The suite will run every time this page is re-loaded.

For Continuous Integration environments, add this task to the project build steps:

`rake jasmine:ci`

This uses Selenium to launch a browser and run the Jasmine suite. Then it uses RSpec to extract the results from the Jasmine reporter and write them to your build log.

## Configuration

Customize `spec/javascripts/support/jasmine.yml` to enumerate the source files, stylesheets, and spec files you would like the Jasmine runner to include.
You may use dir glob strings.

For more complex configuration (e.g., port number), edit `spec/javascripts/support/jasmine_config.rb` file directly.

## Note about the CI task and RSpec

This gem requires RSpec for the `jasmine:ci` rake task to work. But this gem does not explicitly *depend* on any version of the RSpec gem.

If you're writing a Rails application then as long as you've installed RSpec before you install Jasmine and attempt a `rake jasmine:ci`, then you will be fine.

If you're using another Ruby framework, or don't care about Ruby, then run

`gem install rspec`

before you attempt the CI task.

## Support

Jasmine Mailing list: [jasmine-js@googlegroups.com](mailto:jasmine-js@googlegroups.com)
Twitter: [@jasminebdd](http://twitter.com/jasminebdd)

Please file issues here at Github

Copyright (c) 2008-2010 Pivotal Labs. This software is licensed under the MIT License.

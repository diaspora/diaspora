jasmine-gem
============

Jasmine Gem dynamically serves and runs suites for [Jasmine](http://github.com/pivotal/jasmine).

To use:

`gem install jasmine`

Post-installation:

For Rails2 support, use

`script/generate jasmine`

For Rails3 support, use

`bundle exec jasmine init`

For other Ruby projects (including Merb), use

`jasmine init`

After initializing a project, you may

`rake jasmine`

to set up a server. Opening localhost:8888 in a web browser will now run your jasmine specs.

You may also

`rake jasmine:ci`

which will run your Jasmine suites using selenium and rspec. This task is suitable for running in continuous integration environments.  There is currently a known issue using this rake task with RSpec2 beta.

Simple Configuration:

Customize `spec/javascripts/support/jasmine.yml` to enumerate the source files, stylesheets, and spec files you would like the Jasmine runner to include.
You may use dir glob strings.

It is also possible to add overrides into the `spec/javascripts/support/jasmine_config.rb` file directly if you require further customization.

Copyright (c) 2008-2010 Pivotal Labs. This software is licensed under the MIT License.

To test changes to the jasmine-gem:

* Export RAILS_VERSION as either "pojs-rspec1",  "pojs-rspec2", or "rails2" to test environments other than Rails 3.
* Delete `Gemfile.lock`
* Clear out your current gemset
* exec a `bundle install`
* `rake` until specs are green
* Repeat
* Check in

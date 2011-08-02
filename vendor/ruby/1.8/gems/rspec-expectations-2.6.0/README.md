# RSpec Expectations

rspec-expectations adds `should` and `should_not` to every object and includes
RSpec::Matchers, a library of standard matchers.

[![build status](http://travis-ci.org/rspec/rspec-expectations.png)](http://travis-ci.org/rspec/rspec-expectations)

## Documentation

The [Cucumber features](http://relishapp.com/rspec/rspec-expectations)
are the most comprehensive and up-to-date docs for end-users.

The [RDoc](http://rubydoc.info/gems/rspec-expectations/2.3.0/frames) provides
additional information for contributors and/or extenders.

All of the documentation is open source and a work in progress. If you find it
lacking or confusing, you can help improve it by submitting requests and
patches to the [rspec-expectations issue
tracker](https://github.com/rspec/rspec-expectations/issues).

## Install

    gem install rspec               # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-expecctations # for rspec-expectations only

## Matchers

Matchers are objects used to compose expectations:

    result.should eq("this value")

In that example, `eq("this value")` returns a `Matcher` object that
compares the actual `result` to the expected `"this value"`.

## Contribute

See [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)

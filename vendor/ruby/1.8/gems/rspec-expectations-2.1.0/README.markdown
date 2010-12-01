# RSpec Expectations

rspec-expectations adds `should` and `should_not` to every object and includes
RSpec::Matchers, a library of standard matchers.

## Documentation

* [Cucumber features](http://relishapp.com/rspec/rspec-expectations/v/2-0)
* [RDoc](http://rubydoc.info/gems/rspec-expectations/2.0.1/frames)

## Install

    gem install rspec               # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-expecctations # for rspec-core only

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

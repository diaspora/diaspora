# RSpec-2

Behaviour Driven Development for Ruby

# Description

rspec-2.x is a meta-gem, which depends on the rspec-core, rspec-expectations
and rspec-mocks gems. Each of these can be installed separately and actived in
isolation with the `gem` command. Among other benefits, this allows you to use
rspec-expectations, for example, in Test::Unit::TestCase if you happen to
prefer that style.

Conversely, if you like RSpec's approach to declaring example groups and
examples (`describe` and `it`) but prefer Test::Unit assertions and mocha, rr
or flexmock for mocking, you'll be able to do that without having to load the
components of rspec that you're not using.

## Documentation

### rspec-core

* [Cucumber features](http://relishapp.com/rspec/rspec-core/v/2-0)
* [RDoc](http://rubydoc.info/gems/rspec-core/2.0.1/frames)

### rspec-expectations

* [Cucumber features](http://relishapp.com/rspec/rspec-expectations/v/2-0)
* [RDoc](http://rubydoc.info/gems/rspec-expectations/2.0.1/frames)

### rspec-mocks

* [Cucumber features](http://relishapp.com/rspec/rspec-mocks/v/2-0)
* [RDoc](http://rubydoc.info/gems/rspec-mocks/2.0.1/frames)

## Install

    gem install rspec

## Contribute

* [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)

rspec-expectations is used to define expected outcomes.

    describe Account do
      it "has a balance of zero when first created" do
        Account.new.balance.should eq(Money.new(0))
      end
    end

## Basic structure

The basic structure of an rspec expectation is:

    actual.should matcher(expected)
    actual.should_not matcher(expected)

## `should` and `should_not`

`rspec-expectations` adds `should` and `should_not` to every object in
the system. These methods each accept a matcher as an argument. This allows
each matcher to work in a positive or negative mode:

    5.should eq(5)
    5.should_not eq(4)

## What is a matcher?

A Matcher is any object that responds to the following methods:

    matches?(actual)
    failure_message_for_should

These methods are also part of the matcher protocol, but are optional:

    does_not_match?(actual)
    failure_message_for_should_not
    description

RSpec ships with a number of built-in matchers and a DSL for writing custom
matchers.

## Issues

The documentation for rspec-expectations is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-expectations/issues) or a [pull
request](http://github.com/rspec/rspec-expectations).

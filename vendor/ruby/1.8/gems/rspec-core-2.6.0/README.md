# RSpec Core

RSpec Core provides the structure for writing executable examples of how your
code should behave.

[![build status](http://travis-ci.org/rspec/rspec-core.png)](http://travis-ci.org/rspec/rspec-core)

## Documentation

The [Cucumber features](http://relishapp.com/rspec/rspec-core) are the
most comprehensive and up-to-date docs for end-users.

The [RDoc](http://rubydoc.info/gems/rspec-core/2.3.0/frames) provides
additional information for contributors and/or extenders.

All of the documentation is open source and a work in progress. If you find it
lacking or confusing, you can help improve it by submitting requests and
patches to the [rspec-core issue
tracker](https://github.com/rspec/rspec-core/issues).

## Install

    gem install rspec      # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-core # for rspec-core only

## Upgrading from rspec-1.x

See [features/Upgrade.md](http://github.com/rspec/rspec-core/blob/master/features/Upgrade.md)


This will install the rspec, rspec-core, rspec-expectations and rspec-mocks
gems.

## Get Started

Start with a simple example of behavior you expect from your system. Do
this before you write any implementation code:

    # in spec/calculator_spec.rb
    describe Calculator, "add" do
      it "returns the sum of its arguments" do
        Calculator.new.add(1, 2).should eq(3)
      end
    end

Run this with the rspec command, and watch it fail:

    $ rspec spec/calculator_spec.rb
    ./spec/calculator_spec.rb:1: uninitialized constant Calculator

Implement the simplest solution:

    # in lib/calculator.rb
    class Calculator
      def add(a,b)
        a + b
      end
    end

Be sure to require the implementation file in the spec:

    # in spec/calculator_spec.rb
    # - RSpec adds ./lib to the $LOAD_PATH, so you can
    #   just require "calculator" directly
    require "calculator"

Now run the spec again, and watch it pass:

    $ rspec spec/calculator_spec.rb
    .

    Finished in 0.000315 seconds
    1 example, 0 failures

Use the documentation formatter to see the resulting spec:

    $ rspec spec/calculator_spec.rb --format doc
    Calculator add
      returns the sum of its arguments

    Finished in 0.000379 seconds
    1 example, 0 failures

## Known issues

See [http://github.com/rspec/rspec-core/issues](http://github.com/rspec/rspec-core/issues)

## Learn more

While not comprehensive yet, you can learn quite a lot from the Cucumber
features in the [features
directory](http://github.com/rspec/rspec-core/tree/master/features/).  If there
is a feature that is not documented there, or you find them insufficient to
understand how to use a feature, please submit issues to
[http://github.com/rspec/rspec-core/issues](http://github.com/rspec/rspec-core/issues).

## Contribute

See [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)


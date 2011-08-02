# RSpec Mocks

rspec-mocks provides a test-double framework for rspec including support
for method stubs, fakes, and message expectations.

[![build status](http://travis-ci.org/rspec/rspec-mocks.png)](http://travis-ci.org/rspec/rspec-mocks)

## Documentation

The [Cucumber features](http://relishapp.com/rspec/rspec-mocks) are the
most comprehensive and up-to-date docs for end-users.

The [RDoc](http://rubydoc.info/gems/rspec-mocks/2.3.0/frames) provides additional
information for contributors and/or extenders.

All of the documentation is open source and a work in progress. If you find it
lacking or confusing, you can help improve it by submitting requests and
patches to the [rspec-mocks issue
tracker](https://github.com/rspec/rspec-mocks/issues).

## Install

    gem install rspec       # for rspec-core, rspec-expectations, rspec-mocks
    gem install rspec-mocks # for rspec-mocks only

## Method Stubs

    describe "consumer" do
      it "gets stuff from a service" do
        service = double('service')
        service.stub(:find) { 'value' }
        consumer = Consumer.new(service)
        consumer.consume
        consumer.aquired_stuff.should eq(['value'])
      end
    end

## Message Expectations

    describe "some action" do
      context "when bad stuff happens" do
        it "logs the error" do
          logger = double('logger')
          doer = Doer.new(logger)
          logger.should_receive(:log).with('oops')
          doer.do_something_with(:bad_data)
        end
      end
    end

## Contribute

See [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)

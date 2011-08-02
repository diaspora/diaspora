rspec-mocks helps to control the context in a code example by letting you set
known return values, fake implementations of methods, and even expectations
that specific messages are received by an object.

You can do these three things on test doubles that rspec-mocks creates for you
on the fly, or you can do them on objects that are part of your system.

## Messages and Methods

_Message_ and _method_ are metaphors that we use somewhat interchangeably, but
they are subtly different.  In Object Oriented Programming, objects communicate
by sending _messages_ to one another. When an object receives a message, it
invokes a _method_ with the same name as the message.

## Test Doubles

A test double is an object that stands in for another object in your system
during a code example. Use the `double` method to create one:

    double_account = double("Account")

You can also use the `mock` and `stub` methods to create test doubles, however
these methods are there for backward compatibility only and will likely be
deprecated and then removed from future versions.

## Method Stubs

A method stub is an instruction to an object (real or test double) to return a
known value in response to a message:

    die.stub(:roll) { 3 }

This tells the `die` object to return the value `3` when it receives the `roll`
message.

## Message Expectations

A message expectation is an expectation that an object should receive a
specific message during the course of a code example:

    describe Account do
      context "when closed" do
        it "logs an 'account closed' message" do
          logger = double()
          account = Account.new
          account.logger = logger

          logger.should_receive(:account_closed).with(account)

          account.close
        end
      end
    end

This example specifies that the `account` object sends the `logger` the
`account_closed` message (with itself as an argument) when it receives the
`close` message.

## Issues

The documentation for rspec-mocks is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-mocks/issues) or a [pull
request](http://github.com/rspec/rspec-mocks).

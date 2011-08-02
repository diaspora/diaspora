### Stub return values

    obj.stub(:message).and_return('this is the value to return')
    obj.stub(:message) { 'this is the value to return' }

These two forms are somewhat interchangeable. The difference is that the
argument to `and_return` is evaluated immediately, whereas the block contents
are evaluated lazily when the `obj` receives the `message` message.

The block format is generally preferred as it is more terse and more consistent
with other forms described below, but lazy evaluation can be confusing because
things aren't evaluated in the order in which they are declared.

### Fake implementation

    obj.stub(:message) do |arg1, arg2|
      # set expectations about the args in this block
      # and/or set a return value
    end

### Raising/Throwing

    obj.stub(:message).and_raise("this error")
    obj.stub(:message).and_throw(:this_symbol)

You can also use the block format, for consistency with other stubs:

    obj.stub(:message) { raise "this error" }
    obj.stub(:message) { throw :this_symbol }

### Argument constraints
   
#### Explicit arguments

    obj.stub(:message).with('an argument') { ... }
    obj.stub(:message).with('more_than', 'one_argument') { ... }

#### Argument matchers

    obj.stub(:message).with(anything()) { ... }
    obj.stub(:message).with(an_instance_of(Money)) { ... }
    obj.stub(:message).with(hash_including(:a => 'b')) { ... }

#### Regular expressions

    obj.stub(:message).with(/abc/) { ... }


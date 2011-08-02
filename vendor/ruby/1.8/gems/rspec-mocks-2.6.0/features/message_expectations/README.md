### Basics

    # create a double
    obj = double()

    # expect a message
    obj.should_receive(:message)

    # specify a return value
    obj.should_receive(:message) { 'this is the value to return' }

### Argument constraints
   
#### Explicit arguments

    obj.should_receive(:message).with('an argument')
    obj.should_receive(:message).with('more_than', 'one_argument')

#### Argument matchers

    obj.should_receive(:message).with(anything())
    obj.should_receive(:message).with(an_instance_of(Money))
    obj.should_receive(:message).with(hash_including(:a => 'b'))

#### Regular expressions

    obj.should_receive(:message).with(/abc/)

### Counts 

    obj.should_receive(:message).once
    obj.should_receive(:message).twice
    obj.should_receive(:message).exactly(3).times

    obj.should_receive(:message).at_least(:once)
    obj.should_receive(:message).at_least(:twice)
    obj.should_receive(:message).at_least(n).times

    obj.should_receive(:message).at_most(:once)
    obj.should_receive(:message).at_most(:twice)
    obj.should_receive(:message).at_most(n).times

### Raising/Throwing

    obj.should_receive(:message) { raise "this error" }
    obj.should_receive(:message) { throw :this_symbol }

### Ordering

    obj.should_receive(:one).ordered
    obj.should_receive(:two).ordered

### Arbitrary handling

    obj.should_receive(:message) do |arg1, arg2|
      # set expectations about the args in this block
      # and set a return value
    end

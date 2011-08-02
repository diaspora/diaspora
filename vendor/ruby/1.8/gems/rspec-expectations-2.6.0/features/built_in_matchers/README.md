## Object identity

    actual.should equal(expected) # passes if actual.equal?(expected)
    
## Object equivalence

    actual.should == expected   # passes if actual == expected
    actual.should eql(expected) # passes if actual.eql?(expected)

## Optional APIs for identity/equivalence

    actual.should eq(expected)  # passes if actual == expected
    actual.should be(expected)  # passes if actual.equal?(expected)

## Comparisons

    actual.should be >  expected
    actual.should be >= expected
    actual.should be <= expected
    actual.should be <  expected
    actual.should =~ /expression/
    actual.should match(/expression/)
    actual.should be_within(delta).of(expected)

## Types/classes

    actual.should be_instance_of(expected)
    actual.should be_kind_of(expected)

## Truthiness and existentialism

    actual.should be_true  # passes if actual is anything but nil or false
    actual.should be_false # passes if actual is nil or false
    actual.should be_nil   # passes if actual is nil
    actual.should be       # passes if actual is not nil

## Expecting errors

    expect { ... }.to raise_error
    expect { ... }.to raise_error(ErrorClass)
    expect { ... }.to raise_error("message")
    expect { ... }.to raise_error(ErrorClass, "message")

## Expecting throws

    expect { ... }.to throw_symbol
    expect { ... }.to throw_symbol(:symbol)
    expect { ... }.to throw_symbol(:symbol, 'value')

## Predicate matchers

    actual.should be_xxx # passes if actual.xxx?

### Example

    [].should be_empty # passes because [].empty? returns true

## Collection membership

    actual.should include(expected)

### Examples

    [1,2,3].should include(1)
    [1,2,3].should include(1, 2)
    {:a => 'b'}.should include(:a => 'b')
    "this string".should include("is str")

## Ranges (1.9 only)

    (1..10).should cover(3)

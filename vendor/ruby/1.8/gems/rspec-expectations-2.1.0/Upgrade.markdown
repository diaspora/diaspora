# Upgrade to rspec-expectations-2.0

## What's new

### New `eq` matcher.

`RSpec::Matchers` now offers you two approaches to differentiating between
object identity. You can use the rspec-1 approach:

    actual.should == expected     # object equality
    actual.should equal(expected) # object identity

... or, if you prefer:

    actual.should eq(expected) # object equality
    actual.should be(expected) # object identity

## What's been removed

### simple_matcher

Use RSpec::Matchers.define instead. For example, if you had:

    def eat_cheese
      simple_matcher("eat cheese") do |actual|
        actual.eat?(:cheese)
      end
    end

Change it to:

    RSpec::Matchers.define :eat_cheese do
      match do |actual|
        actual.eat?(:cheese)
      end
    end

### wrap_expectation

Use RSpec::Matchers.define instead.

    RSpec::Matchers.define :eat_cheese do
      match do |actual|
        actual.should eat?(:cheese)
      end
    end

    RSpec::Matchers.define :eat_cheese do
      include MyCheesyAssertions
      match_unless_raises Test::Unit::AssertionFailedError do |actual|
        assert_eats_chesse actual
      end
    end

## rspec-expectations release history (incomplete)

### 2.1.0 / 2010-11-07

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.1...v2.1.0)

* Enhancements
  * be_within(delta).of(expected) matcher (Myron Marston)
  * Lots of new Cucumber features (Myron Marston)
  * Raise error if you try "should != expected" on Ruby-1.9 (Myron Marston)
  * Improved failure messages from throw_symbol (Myron Marston)

* Bug fixes
  * Eliminate hard dependency on RSpec::Core (Myron Marston)
  * have_matcher - use pluralize only when ActiveSupport inflections are indeed
    defined (Josep M Bach)
  * throw_symbol matcher no longer swallows exceptions (Myron Marston)
  * fix matcher chaining to avoid name collisions (Myron Marston)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.rc...v2.0.0)

* Enhancements
  * Add match_for_should_not method to matcher DSL (Myron Marston)

* Bug fixes
  * respond_to matcher works correctly with should_not with multiple methods (Myron Marston)
  * include matcher works correctly with should_not with multiple values (Myron Marston)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * require 'rspec/expectations' in a T::U or MiniUnit suite (Josep M. Bach)

* Bug fixes
  * change by 0 passes/fails correctly (Len Smith)
  * Add description to satisfy matcher

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * diffing improvements
    * diff multiline strings
    * don't diff single line strings
    * don't diff numbers (silly)
    * diff regexp + multiline string

* Bug fixes
  * should[_not] change now handles boolean values correctly

### 2.6.0 / 2011-05-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.5.0...v2.6.0)

* Enhancments
  * `change` matcher accepts Regexps (Robert Davis)
  * better descriptions for have_xxx matchers (Magnus Bergmark)
  * range.should cover(*values) (Anders Furseth)

* Bug fixes
  * Removed non-ascii characters that were choking rcov (Geoffrey Byers)
  * change matcher dups arrays and hashes so their before/after states can be
    compared correctly.
  * Fix the order of inclusion of RSpec::Matchers in
    Test::Unit::TestCase and MiniTest::Unit::TestCase to prevent a
    SystemStackError (Myron Marston)

### 2.5.0 / 2011-02-05

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.4.0...v2.5.0)

* Enhancements
  * `should exist` works with `exist?` or `exists?` (Myron Marston)
  * `expect { ... }.not_to do_something` (in addition to `to_not`)

* Documentation
  * improved docs for raise_error matcher (James Almond)

### 2.4.0 / 2011-01-02

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.3.0...v2.4.0)

No functional changes in this release, which was made to align with the
rspec-core-2.4.0 release.

* Enhancements
  * improved RDoc for change matcher (Jo Liss)

### 2.3.0 / 2010-12-12

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.2.1...v2.3.0)

* Enhancements
  * diff strings when include matcher fails (Mike Sassak)

### 2.2.0 / 2010-11-28

[full changelog](http://github.com/rspec/rspec-expectations/compare/v2.1.0...v2.2.0)

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

### 2.6.0 / 2011-05-12

[full changelog](http://github.com/rspec/rspec-core/compare/v2.5.1...v2.6.0)

* Enhancements
  * `shared_context` (Damian Nurzynski)
      * extend groups matching specific metadata with:
          * method definitions
          * subject declarations
          * let/let! declarations
          * etc (anything you can do in a group)
  * `its([:key])` works for any subject with #[]. (Peter Jaros)
  * `treat_symbols_as_metadata_keys_with_true_values` (Myron Marston)
  * Print a deprecation warning when you configure RSpec after defining
    an example.  All configuration should happen before any examples are
    defined. (Myron Marston)
  * Pass the exit status of a DRb run to the invoking process. This causes
    specs run via DRb to not just return true or false. (Ilkka Laukkanen)
  * Refactoring of `ConfigurationOptions#parse_options` (Rodrigo Rosenfeld Rosas)
  * Report excluded filters in runner output (tip from andyl)
  * Clean up messages for filters/tags.
  * Restore --pattern/-P command line option from rspec-1
  * Support false as well as true in config.full_backtrace= (Andreas Tolf Tolfsen)

* Bug fixes
  * Don't stumble over an exception without a message (Hans Hasselberg)
  * Remove non-ascii characters from comments that were choking rcov (Geoffrey
    Byers)
  * Fixed backtrace so it doesn't include lines from before the autorun at_exit
    hook (Myron Marston)
  * Include RSpec::Matchers when first example group is defined, rather
    than just before running the examples.  This works around an obscure
    bug in ruby 1.9 that can cause infinite recursion. (Myron Marston)
  * Don't send `example_group_[started|finished]` to formatters for empty groups.
  * Get specs passing on jruby (Sidu Ponnappa)
  * Fix bug where mixing nested groups and outer-level examples gave
    unpredictable :line_number behavior (Artur Małecki)
  * Regexp.escape the argument to --example (tip from Elliot Winkler)
  * Correctly pass/fail pending block with message expectations
  * CommandLine returns exit status (0/1) instead of true/false
  * Create path to formatter output file if it doesn't exist (marekj).


### 2.5.1 / 2011-02-06

[full changelog](http://github.com/rspec/rspec-core/compare/v2.5.0...v2.5.1)

NOTE: this release breaks compatibility with rspec/autotest/bundler
integration, but does so in order to greatly simplify it.

With this release, if you want the generated autotest command to include
'bundle exec', require Autotest's bundler plugin in a .autotest file in the
project's root directory or in your home directory:

    require "autotest/bundler"

Now you can just type 'autotest' on the commmand line and it will work as you expect.

If you don't want 'bundle exec', there is nothing you have to do.

### 2.5.0 / 2011-02-05

[full changelog](http://github.com/rspec/rspec-core/compare/v2.4.0...v2.5.0)

* Enhancements
  * Autotest::Rspec2 parses command line args passed to autotest after '--'
  * --skip-bundler option for autotest command
  * Autotest regexp fixes (Jon Rowe)
  * Add filters to html and textmate formatters (Daniel Quimper)
  * Explicit passing of block (need for JRuby 1.6) (John Firebaugh)

* Bug fixes
  * fix dom IDs in HTML formatter (Brian Faherty)
  * fix bug with --drb + formatters when not running in drb
  * include --tag options in drb args (monocle)
  * fix regression so now SPEC_OPTS take precedence over CLI options again
    (Roman Chernyatchik)
  * only call its(:attribute) once (failing example from Brian Dunn)
  * fix bizarre bug where rspec would hang after String.alias :to_int :to_i
    (Damian Nurzynski)

* Deprecations
  * implicit inclusion of 'bundle exec' when Gemfile present (use autotest's
    bundler plugin instead)

### 2.4.0 / 2011-01-02

[full changelog](http://github.com/rspec/rspec-core/compare/v2.3.1...v2.4.0)

* Enhancements
  * start the debugger on -d so the stack trace is visible when it stops
    (Clifford Heath)
  * apply hook filtering to examples as well as groups (Myron Marston)
  * support multiple formatters, each with their own output
  * show exception classes in failure messages unless they come from RSpec
    matchers or message expectations
  * before(:all) { pending } sets all examples to pending

* Bug fixes
  * fix bug due to change in behavior of reject in Ruby 1.9.3-dev (Shota Fukumori)
  * fix bug when running in jruby: be explicit about passing block to super
    (John Firebaugh)
  * rake task doesn't choke on paths with quotes (Janmejay Singh)
  * restore --options option from rspec-1
  * require 'ostruct' to fix bug with its([key]) (Kim Burgestrand)
  * --configure option generates .rspec file instead of autotest/discover.rb

### 2.3.1 / 2010-12-16

[full changelog](http://github.com/rspec/rspec-core/compare/v2.3.0...v2.3.1)

* Bug fixes
  * send debugger warning message to $stdout if RSpec.configuration.error_stream
    has not been defined yet.
  * HTML Formatter _finally_ properly displays nested groups (Jarmo Pertman)
  * eliminate some warnings when running RSpec's own suite (Jarmo Pertman)

### 2.3.0 / 2010-12-12

[full changelog](http://github.com/rspec/rspec-core/compare/v2.2.1...v2.3.0)

* Enhancements
  * tell autotest to use "rspec2" if it sees a .rspec file in the project's
    root directory
    * replaces the need for ./autotest/discover.rb, which will not work with
      all versions of ZenTest and/or autotest
  * config.expect_with
    * :rspec          # => rspec/expectations
    * :stdlib         # => test/unit/assertions
    * :rspec, :stdlib # => both

* Bug fixes
  * fix dev Gemfile to work on non-mac-os machines (Lake Denman)
  * ensure explicit subject is only eval'd once (Laszlo Bacsi)

### 2.2.1 / 2010-11-28

[full changelog](http://github.com/rspec/rspec-core/compare/v2.2.0...v2.2.1)

* Bug fixes
  * alias_method instead of override Kernel#method_missing (John Wilger)
  * changed --autotest to --tty in generated command (MIKAMI Yoshiyuki)
  * revert change to debugger (had introduced conflict with Rails)
    * also restored --debugger/-debug option

### 2.2.0 / 2010-11-28

[full changelog](http://github.com/rspec/rspec-core/compare/v2.1.0...v2.2.0)

* Deprecations/changes
  * --debug/-d on command line is deprecated and now has no effect
  * win32console is now ignored; Windows users must use ANSICON for color support
    (Bosko Ivanisevic)

* Enhancements
  * When developing locally rspec-core now works with the rspec-dev setup or your local gems
  * Raise exception with helpful message when rspec-1 is loaded alongside
    rspec-2 (Justin Ko)
  * debugger statements _just work_ as long as ruby-debug is installed
    * otherwise you get warned, but not fired
  * Expose example.metadata in around hooks
  * Performance improvments (much faster now)

* Bug fixes
  * Make sure --fail-fast makes it across drb
  * Pass -Ilib:spec to rcov

### 2.1.0 / 2010-11-07

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.1...v2.1.0)

* Enhancments
  * Add skip_bundler option to rake task to tell rake task to ignore the
    presence of a Gemfile (jfelchner)
  * Add gemfile option to rake task to tell rake task what Gemfile to look
    for (defaults to 'Gemfile')
  * Allow passing caller trace into Metadata to support extensions (Glenn
    Vanderburg)
  * Add deprecation warning for Spec::Runner.configure to aid upgrade from
    RSpec-1
  * Add deprecated Spec::Rake::SpecTask to aid upgrade from RSpec-1
  * Add 'autospec' command with helpful message to aid upgrade from RSpec-1
  * Add support for filtering with tags on CLI (Lailson Bandeira)
  * Add a helpful message about RUBYOPT when require fails in bin/rspec
    (slyphon)
  * Add "-Ilib" to the default rcov options (Tianyi Cui)
  * Make the expectation framework configurable (default rspec, of course)
    (Justin Ko)
  * Add 'pending' to be conditional (Myron Marston)
  * Add explicit support for :if and :unless as metadata keys for conditional run
    of examples (Myron Marston)
  * Add --fail-fast command line option (Jeff Kreeftmeijer)

* Bug fixes
  * Eliminate stack overflow with "subject { self }"
  * Require 'rspec/core' in the Raketask (ensures it required when running rcov)

### 2.0.1 / 2010-10-18

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0...v2.0.1)

* Bug fixes
  * Restore color when using spork + autotest
  * Pending examples without docstrings render the correct message (Josep M. Bach)
  * Fixed bug where a failure in a spec file ending in anything but _spec.rb would
    fail in a confusing way.
  * Support backtrace lines from erb templates in html formatter (Alex Crichton)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.rc...v2.0.0)

* RSpec-1 compatibility
  * Rake task uses ENV["SPEC"] as file list if present

* Bug fixes
  * Bug Fix: optparse --out foo.txt (Leonardo Bessa)
  * Suppress color codes for non-tty output (except autotest)

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * implicitly require unknown formatters so you don't have to require the
    file explicitly on the commmand line (Michael Grosser)
  * add --out/-o option to assign output target
  * added fail_fast configuration option to abort on first failure
  * support a Hash subject (its([:key]) { should == value }) (Josep M. Bach)

* Bug fixes
  * Explicitly require rspec version to fix broken rdoc task (Hans de Graaff)
  * Ignore backtrace lines that come from other languages, like Java or
    Javascript (Charles Lowell)
  * Rake task now does what is expected when setting (or not setting)
    fail_on_error and verbose
  * Fix bug in which before/after(:all) hooks were running on excluded nested
    groups (Myron Marston)
  * Fix before(:all) error handling so that it fails examples in nested groups,
    too (Myron Marston)

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-core/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * removed at_exit hook
  * CTRL-C stops the run (almost) immediately
    * first it cleans things up by running the appropriate after(:all) and after(:suite) hooks
    * then it reports on any examples that have already run
  * cleaned up rake task
    * generate correct task under variety of conditions
    * options are more consistent
    * deprecated redundant options
  * run 'bundle exec autotest' when Gemfile is present
  * support ERB in .rspec options files (Justin Ko)
  * depend on bundler for development tasks (Myron Marston)
  * add example_group_finished to formatters and reporter (Roman Chernyatchik)

* Bug fixes
  * support paths with spaces when using autotest (Andreas Neuhaus)
  * fix module_exec with ruby 1.8.6 (Myron Marston)
  * remove context method from top-level
    * was conflicting with irb, for example
  * errors in before(:all) are now reported correctly (Chad Humphries)

* Removals
  * removed -o --options-file command line option
    * use ./.rspec and ~/.rspec

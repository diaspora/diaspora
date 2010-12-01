# Haml Spec #

Haml Spec provides a basic suite of tests for Haml interpreters.

It is intented for developers who are creating or maintaining an implementation
of the [Haml](http://haml-lang.com) markup language.

At the moment, there are test runners for the [original Haml](http://github.com/nex3/haml)
in Ruby, and for [Lua Haml](http://github.com/norman/lua-haml). Support for
other versions of Haml will be added if their developers/maintainers
are interested in using it.

## The Tests ##

The tests are kept in JSON format for portability across languages.  Each test
is a JSON object with expected input, output, local variables and configuration
parameters (see below).  The test suite only provides tests for features which
are portable, therefore no tests for script are provided, nor for external
filters such as :markdown or :textile.

The one major exception to this are the tests for interpolation, which you may
need to modify with a regular expression to run under PHP or Perl, which
require a symbol before variable names. These tests are included despite being
less than 100% portable because interpolation is an important part of Haml and
can be tricky to implement.

## Running the Tests ##

### Ruby ###

In order to make it as easy as possible for non-Ruby programmers to run the
Ruby Haml tests, the Ruby test runner uses test/unit, rather than something
fancier like Rspec.  To run them you probably only need to install `haml`, and
possibly `ruby` if your platform doesn't come with it by default. If you're
using Ruby 1.8.x, you'll also need to install `json`:

    sudo gem install haml
    # for Ruby 1.8.x; check using "ruby --version" if unsure
    sudo gem install json

Then, running the Ruby test suite is easy:

    ruby ruby_haml_test.rb

### Lua ###

The Lua test depends on [Telescope](http://telescope.luaforge.net/),
[jason4lua](http://json.luaforge.net/), and
[Lua Haml](http://github.com/norman/lua-haml). Install and
run `tsc lua_haml_spec.lua`.

## Contributing ##

### Getting it ###

You can access the [Git repository](http://github.com/norman/haml-spec) at:

    git://github.com/norman/haml-spec.git

Patches are *very* welcome, as are test runners for your Haml implementation.

As long as any test you add run against Ruby Haml and are not redundant, I'll
be very happy to add them.

### Test JSON format ###

    "test name" : {
      "haml" : "haml input",
      "html" : "expected html output",
      "result" : "expected test result",
      "locals" : "local vars",
      "config" : "config params"
    }

* test name: This should be a *very* brief description of what's being tested. It can
  be used by the test runners to name test methods, or to exclude certain tests from being
  run.
* haml: The Haml code to be evaluated. Always required.
* html: The HTML output that should be generated. Required unless "result" is "error".
* result: Can be "pass" or "error". If it's absent, then "pass" is assumed. If it's "error",
  then the goal of the test is to make sure that malformed Haml code generates an error.
* locals: An object containing local variables needed for the test.
* config: An object containing configuration parameters used to run the test.
  The configuration parameters should be usable directly by Ruby's Haml with no
  modification.  If your implementation uses config parameters with different
  names, you may need to process them to make them match your implementation.
  If your implementation has options that do not exist in Ruby's Haml, then you
  should add tests for this in your implementation's test rather than here.

## License ##

  This project is released under the [WTFPL](http://sam.zoy.org/wtfpl/) in order
  to be as usable as possible in any project, commercial or free.

## Author ##

  [Norman Clarke](mailto:norman@njclarke.com)

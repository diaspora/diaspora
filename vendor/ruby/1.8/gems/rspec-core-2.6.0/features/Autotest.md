RSpec ships with a specialized subclass of Autotest. To use it, just add a
`.rspec` file to your project's root directory, and run the `autotest` command
as normal:

    $ autotest

## Bundler

The `autotest` command generates a shell command that runs your specs. If you
are using Bundler, and you want the shell command to include `bundle exec`,
require the Autotest bundler plugin in a `.autotest` file in the project's root
directory or your home directory:

    # in .autotest
    require "autotest/bundler"

## Upgrading from previous versions of rspec

Previous versions of RSpec used a different mechanism for telling autotest to
invoke RSpec's Autotest extension: it generated an `autotest/discover.rb` file
in the project's root directory. This is no longer necessary with the new
approach of RSpec looking for a `.rspec` file, so feel free to delete the
`autotest/discover.rb` file in the project root if you have one.

## Gotchas

### Invalid Option: --tty

The `--tty` option was [added in rspec-core-2.2.1](changelog), and is used
internally by RSpec. If you see an error citing it as an invalid option, you'll
probably see there are two or more versions of rspec-core in the backtrace: one
< 2.2.1 and one >= 2.2.1.

This usually happens because you have a newer rspec-core installed, and an
older rspec-core specified in a Bundler Gemfile. If this is the case, you can:

1. specify the newer version in the Gemfile (recommended)
2. prefix the `autotest` command with `bundle exec`

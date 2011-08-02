The `rspec` command comes with several options you can use to customize RSpec's
behavior, including output formats, filtering examples, etc.

For a full list of options, run the `rspec` command with the `--help` flag:

    $ rspec --help

### Run with `ruby`

Generally, life is simpler if you just use the `rspec` command. If you must use the `ruby`
command, however, you'll want to do the following:

* `require 'rspec/autorun'`

This tells RSpec to run your examples.  Do this in any file that you are
passing to the `ruby` command.

* Update the `LOAD_PATH`

It is conventional to put configuration in and require assorted support files
from `spec/spec_helper.rb`. It is also conventional to require that file from
the spec files using `require 'spec_helper'`. This works because RSpec
implicitly adds the `spec` directory to the `LOAD_PATH`. It also adds `lib`, so
your implementation files will be on the `LOAD_PATH` as well.

If you're using the `ruby` command, you'll need to do this yourself:

    ruby -Ilib -Ispec path/to/spec.rb

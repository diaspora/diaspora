The `rspec:install` generator creates a `.rspec` file, which tells RSpec to
tell Autotest that you're using RSpec. You'll also need to add the ZenTest and
autotest-rails gems to your Gemfile:

    gem "ZenTest", "~> 4.4.2"
    gem "autotest-rails", "~> 4.1.0"

If all of the gems in your Gemfile are installed in system gems, you can just
type

    autotest

If Bundler is managing any gems for you directly (i.e. you've got `:git` or
`:path` attributes in the Gemfile), however, you may need to run

    bundle exec autotest

If you do, you require Autotest's bundler plugin in a `.autotest` file in the
project root directory or your home directory:

    require "autotest/bundler"

Now you can just type `autotest`, it should prefix the generated shell command
with `bundle exec`.

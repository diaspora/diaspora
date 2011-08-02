# rspec-core-2.6

## new APIs for sharing content

Use `shared_context` together with `include_context` to share before/after
hooks, let declarations, and method definitions across example groups.

Use `shared_examples` together with `include_examples` to share examples
across different contexts.

All of the old APIs are still supported, but these 4 are easy to remember, and
serve most use cases.

See `shared_context` and `shared_examples` under "Example Groups" for more
information.

## `treat_symbols_as_metadata_keys_with_true_values`

Yes it's a long name, but it's a great feature, and it's going to be the
default behavior in rspec-3. This lets you add metadata to a group or example
like this:

    describe "something", :awesome do
      ...

And then you can run that group (or example) using the tags feature:

    rspec spec --tag awesome

We're making this an opt-in for rspec-2.6 because `describe "string", :symbol`
is a perfectly legal construct in pre-2.6 releases and we want to maintain
compatibility in minor releases as much as is possible.

# rspec-core-2.3

## `config.expect_with`

Use this to configure RSpec to use rspec/expectations (default),
stdlib assertions (Test::Unit with Ruby 1.8, MiniTest with Ruby 1.9),
or both:

    RSpec.configure do |config|
      config.expect_with :rspec          # => rspec/expectations
      config.expect_with :stdlib         # => Test::Unit or MinitTest
      config.expect_with :rspec, :stdlib # => both
    end

# rspec-core-2.1

## Command line

### `--tags`

Now you can tag groups and examples using metadata and access those tags from
the command line. So if you have a group with `:foo => true`:

    describe "something", :foo => true do
      it "does something" do
        # ...
      end
    end

... now you can run just that group like this:

    rspec spec --tags foo

### `--fail-fast`

Add this flag to the command line to tell rspec to clean up and exit after the
first failure:

    rspec spec --fail-fast

## Metata/filtering

### :if and :unless keys

Use :if and :unless keys to conditionally run examples with simple boolean
expressions:

    describe "something" do
      it "does something", :if => RUBY_VERSION == 1.8.6 do
        # ...
      end
      it "does something", :unless => RUBY_VERSION == 1.8.6 do
        # ...
      end
    end

## Conditionally 'pending' examples

Make examples pending based on a condition.  This is most useful when you
have an example that runs in multiple contexts and fails in one of those due to
a bug in a third-party dependency that you expect to be fixed in the future.

    describe "something" do
      it "does something that doesn't yet work right on JRuby" do
        pending("waiting for the JRuby team to fix issue XYZ", :if => RUBY_PLATFORM == 'java') do
          # the content of your spec
        end
      end
    end

This example would run normally on all ruby interpretters except JRuby.  On JRuby,
it uses the block form of `pending`, which causes the example to still be run and
will remain pending as long as it fails.  In the future, if you upgraded your
JRuby installation to a newer release that allows the example to pass, RSpec
will report it as a failure (`Expected pending '...' to fail.  No Error was raised.`),
so that know that you can remove the call to `pending`.

# New features in rspec-core-2.0

### Runner

The new runner for rspec-2 comes from Micronaut.

### Metadata!

In rspec-2, every example and example group comes with metadata information
like the file and line number on which it was declared, the arguments passed to
`describe` and `it`, etc.  This metadata can be appended to through a hash
argument passed to `describe` or `it`, allowing us to pre and post-process
each example in a variety of ways.

### Filtering

The most obvious use is for filtering the run. For example:

    # in spec/spec_helper.rb
    RSpec.configure do |c|
      c.filter_run :focus => true
    end

    # in any spec file
    describe "something" do
      it "does something", :focus => true do
        # ....
      end
    end

When you run the `rspec` command, rspec will run only the examples that have
`:focus => true` in the hash.

You can also add `run_all_when_everything_filtered` to the config:

    RSpec.configure do |c|
      c.filter_run :focus => true
      c.run_all_when_everything_filtered = true
    end

Now if there are no examples tagged with `:focus => true`, all examples
will be run. This makes it really easy to focus on one example for a
while, but then go back to running all of the examples by removing that
argument from `it`. Works with `describe` too, in which case it runs
all of the examples in that group.

The configuration will accept a lambda, which provides a lot of flexibility
in filtering examples. Say, for example, you have a spec for functionality that
behaves slightly differently in Ruby 1.8 and Ruby 1.9. We have that in
rspec-core, and here's how we're getting the right stuff to run under the
right version:

    # in spec/spec_helper.rb
    RSpec.configure do |c|
      c.exclusion_filter = { :ruby => lambda {|version|
        !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
      }}
    end

    # in any spec file
    describe "something" do
      it "does something", :ruby => 1.8 do
        # ....
      end

      it "does something", :ruby => 1.9 do
        # ....
      end
    end

In this case, we're using `exclusion_filter` instead of `filter_run` or
`filter`, which indicate _inclusion_ filters. So each of those examples is
excluded if we're _not_ running the version of Ruby they work with.

### Shared example groups

Shared example groups are now run in a nested group within the including group
(they used to be run in the same group). Nested groups inherit `before`, `after`,
`around`, and `let` hooks, as well as any methods that are defined in the parent
group.

This new approach provides better encapsulation, better output, and an
opportunity to add contextual information to the shared group via a block
passed to `it_should_behave_like`.

See [features/example\_groups/shared\_example\_group.feature](http://github.com/rspec/rspec-core/blob/master/features/example_groups/shared_example_group.feature) for more information.

NOTICE: The including example groups no longer have access to any of the
methods, hooks, or state defined inside a shared group. This will break rspec-1
specs that were using shared example groups to extend the behavior of including
groups.

# Upgrading from rspec-1.x

### rspec command

The command to run specs is now `rspec` instead of `spec`.

    rspec ./spec

#### Co-habitation of rspec-1 and rspec-2

Early beta versions of RSpec-2 included a `spec` command, which conflicted with
the RSpec-1 `spec` command because RSpec-1's was installed by the rspec gem,
while RSpec-2's is installed by the rspec-core gem.

If you installed one of these early versions, the safest bet is to uninstall
rspec-1 and rspec-core-2, and then reinstall both. After you do this, you will
be able to run rspec-2 like this:

    rspec ./spec

... and rspec-1 like this:

    spec _1.3.1_ ./spec

Rubygems inspects the first argument to any gem executable to see if it's
formatted like a version number surrounded by underscores. If so, it uses that
version (e.g.  `1.3.1`). If not, it uses the most recent version (e.g.
`2.0.0`).

### rake task

A few things changed in the Rake task used to run specs:

1.  The file in which it is defined changed from `spec/rake/spectask` to
    `rspec/core/rake_task`

2.  The `spec_opts` accessor has been deprecated in favor of `rspec_opts`. Also,
    the `rspec` command no longer supports the `--options` command line option
    so the options must be embedded directly in the Rakefile, or stored in the
    `.rspec` files mentioned above.

3.  In RSpec-1, the rake task would read in rcov options from an `rcov.opts`
    file. This is ignored by RSpec-2. RCov options are now set directly on the Rake
    task:

        RSpec::Core::RakeTask.new(:rcov) do |t|
          t.rcov_opts =  %q[--exclude "spec"]
        end

3.  The `spec_files` accessor has been replaced by `pattern`.

        # rspec-1
        require 'spec/rake/spectask'

        Spec::Rake::SpecTask.new do |t|
          t.spec_opts = ['--options', "\"spec/spec.opts\""]
          t.spec_files = FileList['spec/**/*.rb']
        end

        # rspec-2
        require 'rspec/core/rake_task'

        RSpec::Core::RakeTask.new do |t|
          t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
          t.pattern = 'spec/**/*_spec.rb'
        end

### autotest

`autospec` is dead. Long live `autotest`.

### RSpec is the new Spec

The root namespace (top level module) is now `RSpec` instead of `Spec`, and
the root directory under `lib` within all of the `rspec` gems is `rspec` instead of `spec`.

### Configuration

Typically in `spec/spec_helper.rb`, configuration is now done like this:

    RSpec.configure do |c|
      # ....
    end

### .rspec

Command line options can be persisted in a `.rspec` file in a project. You
can also store a `.rspec` file in your home directory (`~/.rspec`) with global
options. Precedence is:

    command line
    ./.rspec
    ~/.rspec

### `context` is no longer a top-level method

We removed `context` from the main object because it was creating conflicts with
IRB and some users who had `Context` domain objects. `describe` is still there,
so if you want to use `context` at the top level, just alias it:

    alias :context :describe

Of course, you can still use `context` to declare a nested group:

    describe "something" do
      context "in some context" do
        it "does something" do
          # ...
        end
      end
    end

### `$KCODE` no longer set implicitly to `'u'`

In RSpec-1, the runner set `$KCODE` to `'u'`, which impacts, among other
things, the behaviour of Regular Expressions when applied to non-ascii
characters. This is no longer the case in RSpec-2.


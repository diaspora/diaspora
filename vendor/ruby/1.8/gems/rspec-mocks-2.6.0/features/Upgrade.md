## rspec-mocks-2.6

### `any_instance`

Set method stubs and message expectations on any instance of a class:

    class Foo; end
    Foo.any_instance.stub(:bar) { 'bar' }
    Foo.new.bar # => 'bar'

## rspec-mocks-2.2

### `require "rspec/mocks/standalone"`

Sets up top-level environment to explore rspec-mocks. Mostly useful in irb:

    $ irb
    > require 'rspec/mocks/standalone'
    > foo = double()
    > foo.stub(:bar) { :baz }
    > foo.bar
      => :baz

# redis-rb

A Ruby client library for the [Redis](http://redis.io) key-value store.

## A note about versions

Versions *1.0.x* target all versions of Redis. You have to use this one if you are using Redis < 1.2.

Version *2.0* is a big refactoring of the previous version and makes little effort to be
backwards-compatible when it shouldn't. It does not support Redis' original protocol, favoring the
new, binary-safe one. You should be using this version if you're running Redis 1.2+.

## Information about Redis

Redis is a key-value store with some interesting features:

1. It's fast.
2. Keys are strings but values are typed. Currently Redis supports strings, lists, sets, sorted sets and hashes. [Atomic operations](http://redis.io/commands) can be done on all of these types.

See [the Redis homepage](http://redis.io) for more information.

## Getting started

You can connect to Redis by instantiating the `Redis` class:

    require "redis"

    redis = Redis.new

This assumes Redis was started with default values listening on `localhost`, port 6379. If you need to connect to a remote server or a different port, try:

    redis = Redis.new(:host => "10.0.1.1", :port => 6380)

To connect to Redis listening on a unix socket, try:

    redis = Redis.new(:path => "/tmp/redis.sock")

Once connected, you can start running commands against Redis:

    >> redis.set "foo", "bar"
    => "OK"

    >> redis.get "foo"
    => "bar"

    >> redis.sadd "users", "albert"
    => true

    >> redis.sadd "users", "bernard"
    => true

    >> redis.sadd "users", "charles"
    => true

How many users?

    >> redis.scard "users"
    => 3

Is `albert` a user?

    >> redis.sismember "users", "albert"
    => true

Is `isabel` a user?

    >> redis.sismember "users", "isabel"
    => false

Handle groups:

    >> redis.sadd "admins", "albert"
    => true

    >> redis.sadd "admins", "isabel"
    => true

Users who are also admins:

    >> redis.sinter "users", "admins"
    => ["albert"]

Users who are not admins:

    >> redis.sdiff "users", "admins"
    => ["bernard", "charles"]

Admins who are not users:

    >> redis.sdiff "admins", "users"
    => ["isabel"]

All users and admins:

    >> redis.sunion "admins", "users"
    => ["albert", "bernard", "charles", "isabel"]


## Storing objects

Redis only stores strings as values. If you want to store an object inside a key, you can use a serialization/deseralization mechanism like JSON:

    >> redis.set "foo", [1, 2, 3].to_json
    => OK

    >> JSON.parse(redis.get("foo"))
    => [1, 2, 3]

## Executing multiple commands atomically

You can use `MULTI/EXEC` to run arbitrary commands in an atomic fashion:

    redis.multi do
      redis.set "foo", "bar"
      redis.incr "baz"
    end

## Multithreaded Operation

Starting with redis-rb 2.2.0, the client is thread-safe by default. To use
earlier versions safely in a multithreaded environment, be sure to initialize
the client with `:thread_safe => true`. Thread-safety can be explicitly
disabled for versions 2.2 and up by initializing the client with `:thread_safe
=> false`.

See the tests and benchmarks for examples.

## Alternate drivers

Non-default connection drivers are only used when they are explicitly required.
By default, redis-rb uses Ruby's socket library to talk with Redis.

### hiredis

Using redis-rb with hiredis-rb (v0.3 or higher) as backend is done by requiring
`redis/connection/hiredis` before requiring `redis`. This will make redis-rb
pick up hiredis as default driver automatically. This driver optimizes for
speed, at the cost of portability. Since hiredis is a C extension, JRuby is not
supported (by default). Use hiredis when you have large array replies (think
`LRANGE`, `SMEMBERS`, `ZRANGE`, etc.) and/or large pipelines of commands.

Using redis-rb with hiredis from a Gemfile:

    gem "hiredis", "~> 0.3.1"
    gem "redis", "~> 2.2.0", :require => ["redis/connection/hiredis", "redis"]

### synchrony

This driver adds support for
[em-synchrony](https://github.com/igrigorik/em-synchrony). Using the synchrony
backend from redis-rb is done by requiring `redis/connection/synchrony` before
requiring `redis`. This driver makes redis-rb work with EventMachine's
asynchronous I/O, while not changing the exposed API. The hiredis gem needs to
be available as well, because the synchrony driver uses hiredis for parsing the
Redis protocol.

Using redis-rb with synchrony from a Gemfile:

    gem "hiredis", "~> 0.3.1"
    gem "em-synchrony"
    gem "redis", "~> 2.2.0", :require => ["redis/connection/synchrony", "redis"]

## Testing

This library (v2.2) is tested against the following interpreters:

* MRI 1.8.7 (drivers: Ruby, hiredis)
* MRI 1.9.2 (drivers: Ruby, hiredis, em-synchrony)
* JRuby 1.6 (drivers: Ruby)
* Rubinius 1.2 (drivers: Ruby, hiredis)

## Known issues

* Ruby 1.9 doesn't raise on socket timeouts in `IO#read` but rather retries the
  read operation. This means socket timeouts don't work on 1.9 when using the
  pure Ruby I/O code. Use hiredis when you want use socket timeouts on 1.9.

* Ruby 1.8 *does* raise on socket timeouts in `IO#read`, but prints a warning
  that using `IO#read` for non blocking reads is obsolete. This is wrong, since
  the read is in fact blocking, but `EAGAIN` (which is returned on socket
  timeouts) is interpreted as if the read was non blocking. Use hiredis to
  prevent seeing this warning.

## More info

Check the [Redis Command Reference](http://redis.io/commands) or check the tests to find out how to use this client.

## Contributors

(ordered chronologically with more than 5 commits, see `git shortlog -sn` for
all contributors)

* Ezra Zygmuntowicz
* Taylor Weibley
* Matthew Clark
* Brian McKinney
* Luca Guidi
* Salvatore Sanfillipo
* Chris Wanstrath
* Damian Janowski
* Michel Martens
* Nick Quaranto
* Pieter Noordhuis
* Ilya Grigorik

## Contributing

[Fork the project](http://github.com/ezmobius/redis-rb) and send pull requests. You can also ask for help at `#redis-rb` on Freenode.

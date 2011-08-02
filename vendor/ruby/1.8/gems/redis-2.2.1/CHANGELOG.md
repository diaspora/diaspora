# 2.2.2 (unreleased)

# 2.2.1

* Internal API: Client#call and family are now called with a single array
  argument, since splatting a large number of arguments (100K+) results in a
  stack overflow on 1.9.2.

* The `INFO` command can optionally take a subcommand. When the subcommand is
  `COMMANDSTATS`, the client will properly format the returned statistics per
  command. Subcommands for `INFO` are available since Redis v2.3.0 (unstable).

* Change `IO#syswrite` back to the buffered `IO#write` since some Rubies do
  short writes for large (1MB+) buffers and some don't (see issue #108).

# 2.2.0

* Added method `Redis#without_reconnect` that ensures the client will not try
  to reconnect when running the code inside the specified block.

* Thread-safe by default. Thread safety can be explicitly disabled by passing
  `:thread_safe => false` as argument.

* Commands called inside a MULTI/EXEC no longer raise error replies, since a
  successful EXEC means the commands inside the block were executed.

* MULTI/EXEC blocks are pipelined.

* Don't disconnect on error replies.

* Use `IO#syswrite` instead of `IO#write` because write buffering is not
  necessary.

* Connect to a unix socket by passing the `:path` option as argument.

* The timeout value is coerced into a float, allowing sub-second timeouts.

* Accept both `:with_scores` _and_ `:withscores` as argument to sorted set
  commands.

* Use [hiredis](https://github.com/pietern/hiredis-rb) (v0.3 or higher) by
  requiring "redis/connection/hiredis".

* Use [em-synchrony](https://github.com/igrigorik/em-synchrony) by requiring
  "redis/connection/synchrony".

# 2.1.1

See commit log.

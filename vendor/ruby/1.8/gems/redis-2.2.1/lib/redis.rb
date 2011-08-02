require "monitor"

class Redis
  class ProtocolError < RuntimeError
    def initialize(reply_type)
      super(<<-EOS.gsub(/(?:^|\n)\s*/, " "))
      Got '#{reply_type}' as initial reply byte.
      If you're running in a multi-threaded environment, make sure you
      pass the :thread_safe option when initializing the connection.
      If you're in a forking environment, such as Unicorn, you need to
      connect to Redis after forking.
      EOS
    end
  end

  module DisableThreadSafety
    def synchronize
      yield
    end
  end

  def self.deprecate(message, trace = caller[0])
    $stderr.puts "\n#{message} (in #{trace})"
  end

  attr :client

  def self.connect(options = {})
    options = options.dup

    require "uri"

    url = URI(options.delete(:url) || ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0")

    options[:host]     ||= url.host
    options[:port]     ||= url.port
    options[:password] ||= url.password
    options[:db]       ||= url.path[1..-1].to_i

    new(options)
  end

  def self.current
    Thread.current[:redis] ||= Redis.connect
  end

  def self.current=(redis)
    Thread.current[:redis] = redis
  end

  include MonitorMixin

  def initialize(options = {})
    @client = Client.new(options)

    if options[:thread_safe] == false
      # Override #synchronize
      extend DisableThreadSafety
    else
      # Monitor#initialize
      super()
    end
  end

  # Run code without the client reconnecting
  def without_reconnect(&block)
    synchronize do
      @client.without_reconnect(&block)
    end
  end

  # Authenticate to the server.
  def auth(password)
    synchronize do
      @client.call [:auth, password]
    end
  end

  # Change the selected database for the current connection.
  def select(db)
    synchronize do
      @client.db = db
      @client.call [:select, db]
    end
  end

  # Get information and statistics about the server.
  def info(cmd = nil)
    synchronize do
      reply = @client.call [:info, cmd].compact

      if reply.kind_of?(String)
        reply = Hash[*reply.split(/:|\r\n/).grep(/^[^#]/)]

        if cmd && cmd.to_s == "commandstats"
          # Extract nested hashes for INFO COMMANDSTATS
          reply = Hash[reply.map do |k, v|
            [k[/^cmdstat_(.*)$/, 1], Hash[*v.split(/,|=/)]]
          end]
        end
      end

      reply
    end
  end

  def config(action, *args)
    synchronize do
      reply = @client.call [:config, action, *args]

      if reply.kind_of?(Array) && action == :get
        Hash[*reply]
      else
        reply
      end
    end
  end

  # Remove all keys from the current database.
  def flushdb
    synchronize do
      @client.call [:flushdb]
    end
  end

  # Remove all keys from all databases.
  def flushall
    synchronize do
      @client.call [:flushall]
    end
  end

  # Synchronously save the dataset to disk.
  def save
    synchronize do
      @client.call [:save]
    end
  end

  # Asynchronously save the dataset to disk.
  def bgsave
    synchronize do
      @client.call [:bgsave]
    end
  end

  # Asynchronously rewrite the append-only file.
  def bgrewriteaof
    synchronize do
      @client.call [:bgrewriteaof]
    end
  end

  # Get the value of a key.
  def get(key)
    synchronize do
      @client.call [:get, key]
    end
  end

  # Returns the bit value at offset in the string value stored at key.
  def getbit(key, offset)
    synchronize do
      @client.call [:getbit, key, offset]
    end
  end

  # Get a substring of the string stored at a key.
  def getrange(key, start, stop)
    synchronize do
      @client.call [:getrange, key, start, stop]
    end
  end

  # Set the string value of a key and return its old value.
  def getset(key, value)
    synchronize do
      @client.call [:getset, key, value]
    end
  end

  # Get the values of all the given keys.
  def mget(*keys)
    synchronize do
      @client.call [:mget, *keys]
    end
  end

  # Append a value to a key.
  def append(key, value)
    synchronize do
      @client.call [:append, key, value]
    end
  end

  def substr(key, start, stop)
    synchronize do
      @client.call [:substr, key, start, stop]
    end
  end

  # Get the length of the value stored in a key.
  def strlen(key)
    synchronize do
      @client.call [:strlen, key]
    end
  end

  # Get all the fields and values in a hash.
  def hgetall(key)
    synchronize do
      reply = @client.call [:hgetall, key]

      if reply.kind_of?(Array)
        Hash[*reply]
      else
        reply
      end
    end
  end

  # Get the value of a hash field.
  def hget(key, field)
    synchronize do
      @client.call [:hget, key, field]
    end
  end

  # Delete a hash field.
  def hdel(key, field)
    synchronize do
      @client.call [:hdel, key, field]
    end
  end

  # Get all the fields in a hash.
  def hkeys(key)
    synchronize do
      @client.call [:hkeys, key]
    end
  end

  # Find all keys matching the given pattern.
  def keys(pattern = "*")
    synchronize do
      reply = @client.call [:keys, pattern]

      if reply.kind_of?(String)
        reply.split(" ")
      else
        reply
      end
    end
  end

  # Return a random key from the keyspace.
  def randomkey
    synchronize do
      @client.call [:randomkey]
    end
  end

  # Echo the given string.
  def echo(value)
    synchronize do
      @client.call [:echo, value]
    end
  end

  # Ping the server.
  def ping
    synchronize do
      @client.call [:ping]
    end
  end

  # Get the UNIX time stamp of the last successful save to disk.
  def lastsave
    synchronize do
      @client.call [:lastsave]
    end
  end

  # Return the number of keys in the selected database.
  def dbsize
    synchronize do
      @client.call [:dbsize]
    end
  end

  # Determine if a key exists.
  def exists(key)
    synchronize do
      _bool @client.call [:exists, key]
    end
  end

  # Get the length of a list.
  def llen(key)
    synchronize do
      @client.call [:llen, key]
    end
  end

  # Get a range of elements from a list.
  def lrange(key, start, stop)
    synchronize do
      @client.call [:lrange, key, start, stop]
    end
  end

  # Trim a list to the specified range.
  def ltrim(key, start, stop)
    synchronize do
      @client.call [:ltrim, key, start, stop]
    end
  end

  # Get an element from a list by its index.
  def lindex(key, index)
    synchronize do
      @client.call [:lindex, key, index]
    end
  end

  # Insert an element before or after another element in a list.
  def linsert(key, where, pivot, value)
    synchronize do
      @client.call [:linsert, key, where, pivot, value]
    end
  end

  # Set the value of an element in a list by its index.
  def lset(key, index, value)
    synchronize do
      @client.call [:lset, key, index, value]
    end
  end

  # Remove elements from a list.
  def lrem(key, count, value)
    synchronize do
      @client.call [:lrem, key, count, value]
    end
  end

  # Append a value to a list.
  def rpush(key, value)
    synchronize do
      @client.call [:rpush, key, value]
    end
  end

  # Append a value to a list, only if the list exists.
  def rpushx(key, value)
    synchronize do
      @client.call [:rpushx, key, value]
    end
  end

  # Prepend a value to a list.
  def lpush(key, value)
    synchronize do
      @client.call [:lpush, key, value]
    end
  end

  # Prepend a value to a list, only if the list exists.
  def lpushx(key, value)
    synchronize do
      @client.call [:lpushx, key, value]
    end
  end

  # Remove and get the last element in a list.
  def rpop(key)
    synchronize do
      @client.call [:rpop, key]
    end
  end

  # Remove and get the first element in a list, or block until one is available.
  def blpop(*args)
    synchronize do
      @client.call_without_timeout(:blpop, *args)
    end
  end

  # Remove and get the last element in a list, or block until one is available.
  def brpop(*args)
    synchronize do
      @client.call_without_timeout(:brpop, *args)
    end
  end

  # Pop a value from a list, push it to another list and return it; or block
  # until one is available.
  def brpoplpush(source, destination, timeout)
    synchronize do
      @client.call_without_timeout(:brpoplpush, source, destination, timeout)
    end
  end

  # Remove the last element in a list, append it to another list and return it.
  def rpoplpush(source, destination)
    synchronize do
      @client.call [:rpoplpush, source, destination]
    end
  end

  # Remove and get the first element in a list.
  def lpop(key)
    synchronize do
      @client.call [:lpop, key]
    end
  end

  # Get all the members in a set.
  def smembers(key)
    synchronize do
      @client.call [:smembers, key]
    end
  end

  # Determine if a given value is a member of a set.
  def sismember(key, member)
    synchronize do
      _bool @client.call [:sismember, key, member]
    end
  end

  # Add a member to a set.
  def sadd(key, value)
    synchronize do
      _bool @client.call [:sadd, key, value]
    end
  end

  # Remove a member from a set.
  def srem(key, value)
    synchronize do
      _bool @client.call [:srem, key, value]
    end
  end

  # Move a member from one set to another.
  def smove(source, destination, member)
    synchronize do
      _bool @client.call [:smove, source, destination, member]
    end
  end

  # Remove and return a random member from a set.
  def spop(key)
    synchronize do
      @client.call [:spop, key]
    end
  end

  # Get the number of members in a set.
  def scard(key)
    synchronize do
      @client.call [:scard, key]
    end
  end

  # Intersect multiple sets.
  def sinter(*keys)
    synchronize do
      @client.call [:sinter, *keys]
    end
  end

  # Intersect multiple sets and store the resulting set in a key.
  def sinterstore(destination, *keys)
    synchronize do
      @client.call [:sinterstore, destination, *keys]
    end
  end

  # Add multiple sets.
  def sunion(*keys)
    synchronize do
      @client.call [:sunion, *keys]
    end
  end

  # Add multiple sets and store the resulting set in a key.
  def sunionstore(destination, *keys)
    synchronize do
      @client.call [:sunionstore, destination, *keys]
    end
  end

  # Subtract multiple sets.
  def sdiff(*keys)
    synchronize do
      @client.call [:sdiff, *keys]
    end
  end

  # Subtract multiple sets and store the resulting set in a key.
  def sdiffstore(destination, *keys)
    synchronize do
      @client.call [:sdiffstore, destination, *keys]
    end
  end

  # Get a random member from a set.
  def srandmember(key)
    synchronize do
      @client.call [:srandmember, key]
    end
  end

  # Add a member to a sorted set, or update its score if it already exists.
  def zadd(key, score, member)
    synchronize do
      _bool @client.call [:zadd, key, score, member]
    end
  end

  # Determine the index of a member in a sorted set.
  def zrank(key, member)
    synchronize do
      @client.call [:zrank, key, member]
    end
  end

  # Determine the index of a member in a sorted set, with scores ordered from
  # high to low.
  def zrevrank(key, member)
    synchronize do
      @client.call [:zrevrank, key, member]
    end
  end

  # Increment the score of a member in a sorted set.
  def zincrby(key, increment, member)
    synchronize do
      @client.call [:zincrby, key, increment, member]
    end
  end

  # Get the number of members in a sorted set.
  def zcard(key)
    synchronize do
      @client.call [:zcard, key]
    end
  end

  # Return a range of members in a sorted set, by index.
  def zrange(key, start, stop, options = {})
    command = CommandOptions.new(options) do |c|
      c.bool :withscores
      c.bool :with_scores
    end

    synchronize do
      @client.call [:zrange, key, start, stop, *command.to_a]
    end
  end

  # Return a range of members in a sorted set, by score.
  def zrangebyscore(key, min, max, options = {})
    command = CommandOptions.new(options) do |c|
      c.splat :limit
      c.bool  :withscores
      c.bool  :with_scores
    end

    synchronize do
      @client.call [:zrangebyscore, key, min, max, *command.to_a]
    end
  end

  # Count the members in a sorted set with scores within the given values.
  def zcount(key, start, stop)
    synchronize do
      @client.call [:zcount, key, start, stop]
    end
  end

  # Return a range of members in a sorted set, by index, with scores ordered
  # from high to low.
  def zrevrange(key, start, stop, options = {})
    command = CommandOptions.new(options) do |c|
      c.bool :withscores
      c.bool :with_scores
    end

    synchronize do
      @client.call [:zrevrange, key, start, stop, *command.to_a]
    end
  end

  # Return a range of members in a sorted set, by score, with scores ordered
  # from high to low.
  def zrevrangebyscore(key, max, min, options = {})
    command = CommandOptions.new(options) do |c|
      c.splat :limit
      c.bool  :withscores
      c.bool  :with_scores
    end

    synchronize do
      @client.call [:zrevrangebyscore, key, max, min, *command.to_a]
    end
  end

  # Remove all members in a sorted set within the given scores.
  def zremrangebyscore(key, min, max)
    synchronize do
      @client.call [:zremrangebyscore, key, min, max]
    end
  end

  # Remove all members in a sorted set within the given indexes.
  def zremrangebyrank(key, start, stop)
    synchronize do
      @client.call [:zremrangebyrank, key, start, stop]
    end
  end

  # Get the score associated with the given member in a sorted set.
  def zscore(key, member)
    synchronize do
      @client.call [:zscore, key, member]
    end
  end

  # Remove a member from a sorted set.
  def zrem(key, member)
    synchronize do
      _bool @client.call [:zrem, key, member]
    end
  end

  # Intersect multiple sorted sets and store the resulting sorted set in a new
  # key.
  def zinterstore(destination, keys, options = {})
    command = CommandOptions.new(options) do |c|
      c.splat :weights
      c.value :aggregate
    end

    synchronize do
      @client.call [:zinterstore, destination, keys.size, *(keys + command.to_a)]
    end
  end

  # Add multiple sorted sets and store the resulting sorted set in a new key.
  def zunionstore(destination, keys, options = {})
    command = CommandOptions.new(options) do |c|
      c.splat :weights
      c.value :aggregate
    end

    synchronize do
      @client.call [:zunionstore, destination, keys.size, *(keys + command.to_a)]
    end
  end

  # Move a key to another database.
  def move(key, db)
    synchronize do
      _bool @client.call [:move, key, db]
    end
  end

  # Set the value of a key, only if the key does not exist.
  def setnx(key, value)
    synchronize do
      _bool @client.call [:setnx, key, value]
    end
  end

  # Delete a key.
  def del(*keys)
    synchronize do
      @client.call [:del, *keys]
    end
  end

  # Rename a key.
  def rename(old_name, new_name)
    synchronize do
      @client.call [:rename, old_name, new_name]
    end
  end

  # Rename a key, only if the new key does not exist.
  def renamenx(old_name, new_name)
    synchronize do
      _bool @client.call [:renamenx, old_name, new_name]
    end
  end

  # Set a key's time to live in seconds.
  def expire(key, seconds)
    synchronize do
      _bool @client.call [:expire, key, seconds]
    end
  end

  # Remove the expiration from a key.
  def persist(key)
    synchronize do
      _bool @client.call [:persist, key]
    end
  end

  # Get the time to live for a key.
  def ttl(key)
    synchronize do
      @client.call [:ttl, key]
    end
  end

  # Set the expiration for a key as a UNIX timestamp.
  def expireat(key, unix_time)
    synchronize do
      _bool @client.call [:expireat, key, unix_time]
    end
  end

  # Set the string value of a hash field.
  def hset(key, field, value)
    synchronize do
      _bool @client.call [:hset, key, field, value]
    end
  end

  # Set the value of a hash field, only if the field does not exist.
  def hsetnx(key, field, value)
    synchronize do
      _bool @client.call [:hsetnx, key, field, value]
    end
  end

  # Set multiple hash fields to multiple values.
  def hmset(key, *attrs)
    synchronize do
      @client.call [:hmset, key, *attrs]
    end
  end

  def mapped_hmset(key, hash)
    hmset(key, *hash.to_a.flatten)
  end

  # Get the values of all the given hash fields.
  def hmget(key, *fields)
    synchronize do
      @client.call [:hmget, key, *fields]
    end
  end

  def mapped_hmget(key, *fields)
    reply = hmget(key, *fields)

    if reply.kind_of?(Array)
      Hash[*fields.zip(reply).flatten]
    else
      reply
    end
  end

  # Get the number of fields in a hash.
  def hlen(key)
    synchronize do
      @client.call [:hlen, key]
    end
  end

  # Get all the values in a hash.
  def hvals(key)
    synchronize do
      @client.call [:hvals, key]
    end
  end

  # Increment the integer value of a hash field by the given number.
  def hincrby(key, field, increment)
    synchronize do
      @client.call [:hincrby, key, field, increment]
    end
  end

  # Discard all commands issued after MULTI.
  def discard
    synchronize do
      @client.call [:discard]
    end
  end

  # Determine if a hash field exists.
  def hexists(key, field)
    synchronize do
      _bool @client.call [:hexists, key, field]
    end
  end

  # Listen for all requests received by the server in real time.
  def monitor(&block)
    synchronize do
      @client.call_loop([:monitor], &block)
    end
  end

  def debug(*args)
    synchronize do
      @client.call [:debug, *args]
    end
  end

  def object(*args)
    synchronize do
      @client.call [:object, *args]
    end
  end

  # Internal command used for replication.
  def sync
    synchronize do
      @client.call [:sync]
    end
  end

  def [](key)
    get(key)
  end

  def []=(key,value)
    set(key, value)
  end

  # Set the string value of a key.
  def set(key, value)
    synchronize do
      @client.call [:set, key, value]
    end
  end

  # Sets or clears the bit at offset in the string value stored at key.
  def setbit(key, offset, value)
    synchronize do
      @client.call [:setbit, key, offset, value]
    end
  end

  # Set the value and expiration of a key.
  def setex(key, ttl, value)
    synchronize do
      @client.call [:setex, key, ttl, value]
    end
  end

  # Overwrite part of a string at key starting at the specified offset.
  def setrange(key, offset, value)
    synchronize do
      @client.call [:setrange, key, offset, value]
    end
  end

  # Set multiple keys to multiple values.
  def mset(*args)
    synchronize do
      @client.call [:mset, *args]
    end
  end

  def mapped_mset(hash)
    mset(*hash.to_a.flatten)
  end

  # Set multiple keys to multiple values, only if none of the keys exist.
  def msetnx(*args)
    synchronize do
      @client.call [:msetnx, *args]
    end
  end

  def mapped_msetnx(hash)
    msetnx(*hash.to_a.flatten)
  end

  def mapped_mget(*keys)
    reply = mget(*keys)

    if reply.kind_of?(Array)
      Hash[*keys.zip(reply).flatten]
    else
      reply
    end
  end

  # Sort the elements in a list, set or sorted set.
  def sort(key, options = {})
    command = CommandOptions.new(options) do |c|
      c.value :by
      c.splat :limit
      c.multi :get
      c.words :order
      c.value :store
    end

    synchronize do
      @client.call [:sort, key, *command.to_a]
    end
  end

  # Increment the integer value of a key by one.
  def incr(key)
    synchronize do
      @client.call [:incr, key]
    end
  end

  # Increment the integer value of a key by the given number.
  def incrby(key, increment)
    synchronize do
      @client.call [:incrby, key, increment]
    end
  end

  # Decrement the integer value of a key by one.
  def decr(key)
    synchronize do
      @client.call [:decr, key]
    end
  end

  # Decrement the integer value of a key by the given number.
  def decrby(key, decrement)
    synchronize do
      @client.call [:decrby, key, decrement]
    end
  end

  # Determine the type stored at key.
  def type(key)
    synchronize do
      @client.call [:type, key]
    end
  end

  # Close the connection.
  def quit
    synchronize do
      begin
        @client.call [:quit]
      rescue Errno::ECONNRESET
      ensure
        @client.disconnect
      end
    end
  end

  # Synchronously save the dataset to disk and then shut down the server.
  def shutdown
    synchronize do
      @client.call_without_reply [:shutdown]
    end
  end

  # Make the server a slave of another instance, or promote it as master.
  def slaveof(host, port)
    synchronize do
      @client.call [:slaveof, host, port]
    end
  end

  def pipelined(options = {})
    synchronize do
      begin
        original, @client = @client, Pipeline.new
        yield
        original.call_pipelined(@client.commands, options) unless @client.commands.empty?
      ensure
        @client = original
      end
    end
  end

  # Watch the given keys to determine execution of the MULTI/EXEC block.
  def watch(*keys)
    synchronize do
      @client.call [:watch, *keys]
    end
  end

  # Forget about all watched keys.
  def unwatch
    synchronize do
      @client.call [:unwatch]
    end
  end

  # Execute all commands issued after MULTI.
  def exec
    synchronize do
      @client.call [:exec]
    end
  end

  # Mark the start of a transaction block.
  def multi
    synchronize do
      if !block_given?
        @client.call :multi
      else
        result = pipelined(:raise => false) do
          multi
          yield(self)
          exec
        end

        result.last
      end
    end
  end

  # Post a message to a channel.
  def publish(channel, message)
    synchronize do
      @client.call [:publish, channel, message]
    end
  end

  def subscribed?
    synchronize do
      @client.kind_of? SubscribedClient
    end
  end

  # Stop listening for messages posted to the given channels.
  def unsubscribe(*channels)
    synchronize do
      raise RuntimeError, "Can't unsubscribe if not subscribed." unless subscribed?
      @client.unsubscribe(*channels)
    end
  end

  # Stop listening for messages posted to channels matching the given patterns.
  def punsubscribe(*channels)
    synchronize do
      raise RuntimeError, "Can't unsubscribe if not subscribed." unless subscribed?
      @client.punsubscribe(*channels)
    end
  end

  # Listen for messages published to the given channels.
  def subscribe(*channels, &block)
    synchronize do
      subscription(:subscribe, channels, block)
    end
  end

  # Listen for messages published to channels matching the given patterns.
  def psubscribe(*channels, &block)
    synchronize do
      subscription(:psubscribe, channels, block)
    end
  end

  def id
    synchronize do
      @client.id
    end
  end

  def inspect
    synchronize do
      "#<Redis client v#{Redis::VERSION} connected to #{id} (Redis v#{info["redis_version"]})>"
    end
  end

  def method_missing(command, *args)
    synchronize do
      @client.call [command, *args]
    end
  end

  class CommandOptions
    def initialize(options)
      @result = []
      @options = options
      yield(self)
    end

    def bool(name)
      insert(name) { |argument, value| [argument] }
    end

    def value(name)
      insert(name) { |argument, value| [argument, value] }
    end

    def splat(name)
      insert(name) { |argument, value| [argument, *value] }
    end

    def multi(name)
      insert(name) { |argument, value| [argument].product(Array(value)).flatten }
    end

    def words(name)
      insert(name) { |argument, value| value.split(" ") }
    end

    def to_a
      @result
    end

    def insert(name)
      @result += yield(name.to_s.upcase.gsub("_", ""), @options[name]) if @options[name]
    end
  end

private

  # Commands returning 1 for true and 0 for false may be executed in a pipeline
  # where the method call will return nil. Propagate the nil instead of falsely
  # returning false.
  def _bool(value)
    value == 1 if value
  end

  def subscription(method, channels, block)
    return @client.call [method, *channels] if subscribed?

    begin
      original, @client = @client, SubscribedClient.new(@client)
      @client.send(method, *channels, &block)
    ensure
      @client = original
    end
  end

end

require "redis/version"
require "redis/connection"
require "redis/client"
require "redis/pipeline"
require "redis/subscribe"
require "redis/compat"

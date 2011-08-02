require "redis/hash_ring"

class Redis
  class Distributed

    class CannotDistribute < RuntimeError
      def initialize(command)
        @command = command
      end

      def message
        "#{@command.to_s.upcase} cannot be used in Redis::Distributed because the keys involved need to be on the same server or because we cannot guarantee that the operation will be atomic."
      end
    end

    attr_reader :ring

    def initialize(urls, options = {})
      @tag = options.delete(:tag) || /^\{(.+?)\}/
      @default_options = options
      @ring = HashRing.new urls.map { |url| Redis.connect(options.merge(:url => url)) }
      @subscribed_node = nil
    end

    def node_for(key)
      @ring.get_node(key_tag(key.to_s) || key.to_s)
    end

    def nodes
      @ring.nodes
    end

    def add_node(url)
      @ring.add_node Redis.connect(@default_options.merge(:url => url))
    end

    # Close the connection.
    def quit
      on_each_node :quit
    end

    # Change the selected database for the current connection.
    def select(db)
      on_each_node :select, db
    end

    # Ping the server.
    def ping
      on_each_node :ping
    end

    # Remove all keys from all databases.
    def flushall
      on_each_node :flushall
    end

    # Determine if a key exists.
    def exists(key)
      node_for(key).exists(key)
    end

    # Delete a key.
    def del(*args)
      keys_per_node = args.group_by { |key| node_for(key) }
      keys_per_node.inject(0) do |sum, (node, keys)|
        sum + node.del(*keys)
      end
    end

    # Determine the type stored at key.
    def type(key)
      node_for(key).type(key)
    end

    # Find all keys matching the given pattern.
    def keys(glob = "*")
      on_each_node(:keys, glob).flatten
    end

    # Return a random key from the keyspace.
    def randomkey
      raise CannotDistribute, :randomkey
    end

    # Rename a key.
    def rename(old_name, new_name)
      ensure_same_node(:rename, old_name, new_name) do |node|
        node.rename(old_name, new_name)
      end
    end

    # Rename a key, only if the new key does not exist.
    def renamenx(old_name, new_name)
      ensure_same_node(:renamenx, old_name, new_name) do |node|
        node.renamenx(old_name, new_name)
      end
    end

    # Return the number of keys in the selected database.
    def dbsize
      on_each_node :dbsize
    end

    # Set a key's time to live in seconds.
    def expire(key, seconds)
      node_for(key).expire(key, seconds)
    end

    # Set the expiration for a key as a UNIX timestamp.
    def expireat(key, unix_time)
      node_for(key).expireat(key, unix_time)
    end

    # Remove the expiration from a key.
    def persist(key)
      node_for(key).persist(key)
    end

    # Get the time to live for a key.
    def ttl(key)
      node_for(key).ttl(key)
    end

    # Move a key to another database.
    def move(key, db)
      node_for(key).move(key, db)
    end

    # Remove all keys from the current database.
    def flushdb
      on_each_node :flushdb
    end

    # Set the string value of a key.
    def set(key, value)
      node_for(key).set(key, value)
    end

    # Sets or clears the bit at offset in the string value stored at key.
    def setbit(key, offset, value)
      node_for(key).setbit(key, offset, value)
    end

    # Overwrite part of a string at key starting at the specified offset.
    def setrange(key, offset, value)
      node_for(key).setrange(key, offset, value)
    end

    # Set the value and expiration of a key.
    def setex(key, ttl, value)
      node_for(key).setex(key, ttl, value)
    end

    # Get the value of a key.
    def get(key)
      node_for(key).get(key)
    end

    # Returns the bit value at offset in the string value stored at key.
    def getbit(key, offset)
      node_for(key).getbit(key, offset)
    end

    # Get a substring of the string stored at a key.
    def getrange(key, start, stop)
      node_for(key).getrange(key, start, stop)
    end

    # Set the string value of a key and return its old value.
    def getset(key, value)
      node_for(key).getset(key, value)
    end

    def [](key)
      get(key)
    end

    # Append a value to a key.
    def append(key, value)
      node_for(key).append(key, value)
    end

    def substr(key, start, stop)
      node_for(key).substr(key, start, stop)
    end

    def []=(key,value)
      set(key, value)
    end

    # Get the values of all the given keys.
    def mget(*keys)
      raise CannotDistribute, :mget
    end

    def mapped_mget(*keys)
      raise CannotDistribute, :mapped_mget
    end

    # Set the value of a key, only if the key does not exist.
    def setnx(key, value)
      node_for(key).setnx(key, value)
    end

    # Set multiple keys to multiple values.
    def mset(*args)
      raise CannotDistribute, :mset
    end

    def mapped_mset(hash)
      mset(*hash.to_a.flatten)
    end

    # Set multiple keys to multiple values, only if none of the keys exist.
    def msetnx(*args)
      raise CannotDistribute, :msetnx
    end

    def mapped_msetnx(hash)
      raise CannotDistribute, :mapped_msetnx
    end

    # Increment the integer value of a key by one.
    def incr(key)
      node_for(key).incr(key)
    end

    # Increment the integer value of a key by the given number.
    def incrby(key, increment)
      node_for(key).incrby(key, increment)
    end

    # Decrement the integer value of a key by one.
    def decr(key)
      node_for(key).decr(key)
    end

    # Decrement the integer value of a key by the given number.
    def decrby(key, decrement)
      node_for(key).decrby(key, decrement)
    end

    # Append a value to a list.
    def rpush(key, value)
      node_for(key).rpush(key, value)
    end

    # Prepend a value to a list.
    def lpush(key, value)
      node_for(key).lpush(key, value)
    end

    # Get the length of a list.
    def llen(key)
      node_for(key).llen(key)
    end

    # Get a range of elements from a list.
    def lrange(key, start, stop)
      node_for(key).lrange(key, start, stop)
    end

    # Trim a list to the specified range.
    def ltrim(key, start, stop)
      node_for(key).ltrim(key, start, stop)
    end

    # Get an element from a list by its index.
    def lindex(key, index)
      node_for(key).lindex(key, index)
    end

    # Set the value of an element in a list by its index.
    def lset(key, index, value)
      node_for(key).lset(key, index, value)
    end

    # Remove elements from a list.
    def lrem(key, count, value)
      node_for(key).lrem(key, count, value)
    end

    # Remove and get the first element in a list.
    def lpop(key)
      node_for(key).lpop(key)
    end

    # Remove and get the last element in a list.
    def rpop(key)
      node_for(key).rpop(key)
    end

    # Remove the last element in a list, append it to another list and return
    # it.
    def rpoplpush(source, destination)
      ensure_same_node(:rpoplpush, source, destination) do |node|
        node.rpoplpush(source, destination)
      end
    end

    # Remove and get the first element in a list, or block until one is
    # available.
    def blpop(key, timeout)
      node_for(key).blpop(key, timeout)
    end

    # Remove and get the last element in a list, or block until one is
    # available.
    def brpop(key, timeout)
      node_for(key).brpop(key, timeout)
    end

    # Pop a value from a list, push it to another list and return it; or block
    # until one is available.
    def brpoplpush(source, destination, timeout)
      ensure_same_node(:brpoplpush, source, destination) do |node|
        node.brpoplpush(source, destination, timeout)
      end
    end

    # Add a member to a set.
    def sadd(key, value)
      node_for(key).sadd(key, value)
    end

    # Remove a member from a set.
    def srem(key, value)
      node_for(key).srem(key, value)
    end

    # Remove and return a random member from a set.
    def spop(key)
      node_for(key).spop(key)
    end

    # Move a member from one set to another.
    def smove(source, destination, member)
      ensure_same_node(:smove, source, destination) do |node|
        node.smove(source, destination, member)
      end
    end

    # Get the number of members in a set.
    def scard(key)
      node_for(key).scard(key)
    end

    # Determine if a given value is a member of a set.
    def sismember(key, member)
      node_for(key).sismember(key, member)
    end

    # Intersect multiple sets.
    def sinter(*keys)
      ensure_same_node(:sinter, *keys) do |node|
        node.sinter(*keys)
      end
    end

    # Intersect multiple sets and store the resulting set in a key.
    def sinterstore(destination, *keys)
      ensure_same_node(:sinterstore, destination, *keys) do |node|
        node.sinterstore(destination, *keys)
      end
    end

    # Add multiple sets.
    def sunion(*keys)
      ensure_same_node(:sunion, *keys) do |node|
        node.sunion(*keys)
      end
    end

    # Add multiple sets and store the resulting set in a key.
    def sunionstore(destination, *keys)
      ensure_same_node(:sunionstore, destination, *keys) do |node|
        node.sunionstore(destination, *keys)
      end
    end

    # Subtract multiple sets.
    def sdiff(*keys)
      ensure_same_node(:sdiff, *keys) do |node|
        node.sdiff(*keys)
      end
    end

    # Subtract multiple sets and store the resulting set in a key.
    def sdiffstore(destination, *keys)
      ensure_same_node(:sdiffstore, destination, *keys) do |node|
        node.sdiffstore(destination, *keys)
      end
    end

    # Get all the members in a set.
    def smembers(key)
      node_for(key).smembers(key)
    end

    # Get a random member from a set.
    def srandmember(key)
      node_for(key).srandmember(key)
    end

    # Add a member to a sorted set, or update its score if it already exists.
    def zadd(key, score, member)
      node_for(key).zadd(key, score, member)
    end

    # Remove a member from a sorted set.
    def zrem(key, member)
      node_for(key).zrem(key, member)
    end

    # Increment the score of a member in a sorted set.
    def zincrby(key, increment, member)
      node_for(key).zincrby(key, increment, member)
    end

    # Return a range of members in a sorted set, by index.
    def zrange(key, start, stop, options = {})
      node_for(key).zrange(key, start, stop, options)
    end

    # Determine the index of a member in a sorted set.
    def zrank(key, member)
      node_for(key).zrank(key, member)
    end

    # Determine the index of a member in a sorted set, with scores ordered from
    # high to low.
    def zrevrank(key, member)
      node_for(key).zrevrank(key, member)
    end

    # Return a range of members in a sorted set, by index, with scores ordered
    # from high to low.
    def zrevrange(key, start, stop, options = {})
      node_for(key).zrevrange(key, start, stop, options)
    end

    # Remove all members in a sorted set within the given scores.
    def zremrangebyscore(key, min, max)
      node_for(key).zremrangebyscore(key, min, max)
    end

    # Remove all members in a sorted set within the given indexes.
    def zremrangebyrank(key, start, stop)
      node_for(key).zremrangebyrank(key, start, stop)
    end

    # Return a range of members in a sorted set, by score.
    def zrangebyscore(key, min, max, options = {})
      node_for(key).zrangebyscore(key, min, max, options)
    end

    # Return a range of members in a sorted set, by score, with scores ordered
    # from high to low.
    def zrevrangebyscore(key, max, min, options = {})
      node_for(key).zrevrangebyscore(key, max, min, options)
    end

    # Get the number of members in a sorted set.
    def zcard(key)
      node_for(key).zcard(key)
    end

    # Get the score associated with the given member in a sorted set.
    def zscore(key, member)
      node_for(key).zscore(key, member)
    end

    # Intersect multiple sorted sets and store the resulting sorted set in a new
    # key.
    def zinterstore(destination, keys, options = {})
      ensure_same_node(:zinterstore, destination, *keys) do |node|
        node.zinterstore(destination, keys, options)
      end
    end

    # Add multiple sorted sets and store the resulting sorted set in a new key.
    def zunionstore(destination, keys, options = {})
      ensure_same_node(:zunionstore, destination, *keys) do |node|
        node.zunionstore(destination, keys, options)
      end
    end

    # Set the string value of a hash field.
    def hset(key, field, value)
      node_for(key).hset(key, field, value)
    end

    # Get the value of a hash field.
    def hget(key, field)
      node_for(key).hget(key, field)
    end

    # Delete a hash field.
    def hdel(key, field)
      node_for(key).hdel(key, field)
    end

    # Determine if a hash field exists.
    def hexists(key, field)
      node_for(key).hexists(key, field)
    end

    # Get the number of fields in a hash.
    def hlen(key)
      node_for(key).hlen(key)
    end

    # Get all the fields in a hash.
    def hkeys(key)
      node_for(key).hkeys(key)
    end

    # Get all the values in a hash.
    def hvals(key)
      node_for(key).hvals(key)
    end

    # Get all the fields and values in a hash.
    def hgetall(key)
      node_for(key).hgetall(key)
    end

    # Set multiple hash fields to multiple values.
    def hmset(key, *attrs)
      node_for(key).hmset(key, *attrs)
    end

    def mapped_hmset(key, hash)
      node_for(key).hmset(key, *hash.to_a.flatten)
    end

    # Get the values of all the given hash fields.
    def hmget(key, *fields)
      node_for(key).hmget(key, *fields)
    end

    def mapped_hmget(key, *fields)
      Hash[*fields.zip(hmget(key, *fields)).flatten]
    end

    # Increment the integer value of a hash field by the given number.
    def hincrby(key, field, increment)
      node_for(key).hincrby(key, field, increment)
    end

    # Sort the elements in a list, set or sorted set.
    def sort(key, options = {})
      keys = [key, options[:by], options[:store], *Array(options[:get])].compact

      ensure_same_node(:sort, *keys) do |node|
        node.sort(key, options)
      end
    end

    # Mark the start of a transaction block.
    def multi
      raise CannotDistribute, :multi
    end

    # Watch the given keys to determine execution of the MULTI/EXEC block.
    def watch(*keys)
      raise CannotDistribute, :watch
    end

    # Forget about all watched keys.
    def unwatch
      raise CannotDistribute, :unwatch
    end

    # Execute all commands issued after MULTI.
    def exec
      raise CannotDistribute, :exec
    end

    # Discard all commands issued after MULTI.
    def discard
      raise CannotDistribute, :discard
    end

    # Post a message to a channel.
    def publish(channel, message)
      node_for(channel).publish(channel, message)
    end

    def subscribed?
      !! @subscribed_node
    end

    # Stop listening for messages posted to the given channels.
    def unsubscribe(*channels)
      raise RuntimeError, "Can't unsubscribe if not subscribed." unless subscribed?
      @subscribed_node.unsubscribe(*channels)
    end

    # Listen for messages published to the given channels.
    def subscribe(channel, *channels, &block)
      if channels.empty?
        @subscribed_node = node_for(channel)
        @subscribed_node.subscribe(channel, &block)
      else
        ensure_same_node(:subscribe, channel, *channels) do |node|
          @subscribed_node = node
          node.subscribe(channel, *channels, &block)
        end
      end
    end

    # Stop listening for messages posted to channels matching the given
    # patterns.
    def punsubscribe(*channels)
      raise NotImplementedError
    end

    # Listen for messages published to channels matching the given patterns.
    def psubscribe(*channels, &block)
      raise NotImplementedError
    end

    # Synchronously save the dataset to disk.
    def save
      on_each_node :save
    end

    # Asynchronously save the dataset to disk.
    def bgsave
      on_each_node :bgsave
    end

    # Get the UNIX time stamp of the last successful save to disk.
    def lastsave
      on_each_node :lastsave
    end

    # Get information and statistics about the server.
    def info(cmd = nil)
      on_each_node :info, cmd
    end

    # Listen for all requests received by the server in real time.
    def monitor
      raise NotImplementedError
    end

    # Echo the given string.
    def echo(value)
      on_each_node :echo, value
    end

    def pipelined
      raise CannotDistribute, :pipelined
    end

    def inspect
      node_info = nodes.map do |node|
        "#{node.id} (Redis v#{node.info['redis_version']})"
      end
      "#<Redis client v#{Redis::VERSION} connected to #{node_info.join(', ')}>"
    end

  protected

    def on_each_node(command, *args)
      nodes.map do |node|
        node.send(command, *args)
      end
    end

    def node_index_for(key)
      nodes.index(node_for(key))
    end

    def key_tag(key)
      key.to_s[@tag, 1] if @tag
    end

    def ensure_same_node(command, *keys)
      tags = keys.map { |key| key_tag(key) }

      raise CannotDistribute, command if !tags.all? || tags.uniq.size != 1

      yield(node_for(keys.first))
    end
  end
end

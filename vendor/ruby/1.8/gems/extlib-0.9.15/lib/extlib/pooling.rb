require 'set'
require 'thread'

module Extlib
  # ==== Notes
  # Provides pooling support to class it got included in.
  #
  # Pooling of objects is a faster way of aquiring instances
  # of objects compared to regular allocation and initialization
  # because instances are keeped in memory reused.
  #
  # Classes that include Pooling module have re-defined new
  # method that returns instances acquired from pool.
  #
  # Term resource is used for any type of poolable objects
  # and should NOT be thought as DataMapper Resource or
  # ActiveResource resource and such.
  #
  # In Data Objects connections are pooled so that it is
  # unnecessary to allocate and initialize connection object
  # each time connection is needed, like per request in a
  # web application.
  #
  # Pool obviously has to be thread safe because state of
  # object is reset when it is released.
  module Pooling

    def self.scavenger?
      defined?(@scavenger) && !@scavenger.nil? && @scavenger.alive?
    end

    def self.scavenger
      unless scavenger?
        @scavenger = Thread.new do
          running = true
          while running do
            # Sleep before we actually start doing anything.
            # Otherwise we might clean up something we just made
            sleep(scavenger_interval)

            lock.synchronize do
              pools.each do |pool|
                # This is a useful check, but non-essential, and right now it breaks lots of stuff.
                # if pool.expired?
                pool.lock.synchronize do
                  if pool.expired?
                    pool.dispose
                  end
                end
                # end
              end

              # The pool is empty, we stop the scavenger
              # It wil be restarted if new resources are added again
              if pools.empty?
                running = false
              end
            end
          end # loop
        end
      end

      @scavenger.priority = -10
      @scavenger
    end

    def self.pools
      @pools ||= Set.new
    end

    def self.append_pool(pool)
      lock.synchronize do
        pools << pool
      end
      Extlib::Pooling.scavenger
    end

    def self.lock
      @lock ||= Mutex.new
    end

    class InvalidResourceError < StandardError
    end

    def self.included(target)
      target.class_eval do
        class << self
          alias __new new
        end

        @__pools     = {}
        @__pool_lock = Mutex.new
        @__pool_wait = ConditionVariable.new

        def self.__pool_lock
          @__pool_lock
        end

        def self.__pool_wait
          @__pool_wait
        end

        def self.new(*args)
          (@__pools[args] ||= __pool_lock.synchronize { Pool.new(self.pool_size, self, args) }).new
        end

        def self.__pools
          @__pools
        end

        def self.pool_size
          8
        end
      end
    end

    def release
      @__pool.release(self) unless @__pool.nil?
    end

    def detach
      @__pool.delete(self) unless @__pool.nil?
    end

    class Pool
      attr_reader :available
      attr_reader :used

      def initialize(max_size, resource, args)
        raise ArgumentError.new("+max_size+ should be a Fixnum but was #{max_size.inspect}") unless Fixnum === max_size
        raise ArgumentError.new("+resource+ should be a Class but was #{resource.inspect}") unless Class === resource

        @max_size = max_size
        @resource = resource
        @args = args

        @available = []
        @used      = {}
        Extlib::Pooling.append_pool(self)
      end

      def lock
        @resource.__pool_lock
      end

      def wait
        @resource.__pool_wait
      end

      def scavenge_interval
        @resource.scavenge_interval
      end

      def new
        instance = nil
        begin
          lock.synchronize do
            if @available.size > 0
              instance = @available.pop
              @used[instance.object_id] = instance
            elsif @used.size < @max_size
              instance = @resource.__new(*@args)
              raise InvalidResourceError.new("#{@resource} constructor created a nil object") if instance.nil?
              raise InvalidResourceError.new("#{instance} is already part of the pool") if @used.include? instance
              instance.instance_variable_set(:@__pool, self)
              instance.instance_variable_set(:@__allocated_in_pool, Time.now)
              @used[instance.object_id] = instance
            else
              # Wait for another thread to release an instance.
              # If we exhaust the pool and don't release the active instance,
              # we'll wait here forever, so it's *very* important to always
              # release your services and *never* exhaust the pool within
              # a single thread.
              wait.wait(lock)
            end
          end
        end until instance
        instance
      end

      def release(instance)
        lock.synchronize do
          instance.instance_variable_set(:@__allocated_in_pool, Time.now)
          @used.delete(instance.object_id)
          @available.push(instance)
          wait.signal
        end
        nil
      end

      def delete(instance)
        lock.synchronize do
          instance.instance_variable_set(:@__pool, nil)
          @used.delete(instance.object_id)
          wait.signal
        end
        nil
      end

      def size
        @used.size + @available.size
      end
      alias length size

      def inspect
        "#<Extlib::Pooling::Pool<#{@resource.name}> available=#{@available.size} used=#{@used.size} size=#{@max_size}>"
      end

      def flush!
        @available.pop.dispose until @available.empty?
      end

      def dispose
        flush!
        @resource.__pools.delete(@args)
        !Extlib::Pooling.pools.delete?(self).nil?
      end

      def expired?
        @available.each do |instance|
          if Extlib.exiting || instance.instance_variable_get(:@__allocated_in_pool) + Extlib::Pooling.scavenger_interval <= (Time.now + 0.02)
            instance.dispose
            @available.delete(instance)
          end
        end
        size == 0
      end

    end

    def self.scavenger_interval
      60
    end
  end # module Pooling
end # module Extlib

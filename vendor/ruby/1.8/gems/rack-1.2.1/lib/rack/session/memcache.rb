# AUTHOR: blink <blinketje@gmail.com>; blink#ruby-lang@irc.freenode.net

require 'rack/session/abstract/id'
require 'memcache'

module Rack
  module Session
    # Rack::Session::Memcache provides simple cookie based session management.
    # Session data is stored in memcached. The corresponding session key is
    # maintained in the cookie.
    # You may treat Session::Memcache as you would Session::Pool with the
    # following caveats.
    #
    # * Setting :expire_after to 0 would note to the Memcache server to hang
    #   onto the session data until it would drop it according to it's own
    #   specifications. However, the cookie sent to the client would expire
    #   immediately.
    #
    # Note that memcache does drop data before it may be listed to expire. For
    # a full description of behaviour, please see memcache's documentation.

    class Memcache < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :namespace => 'rack:session',
        :memcache_server => 'localhost:11211'

      def initialize(app, options={})
        super

        @mutex = Mutex.new
        mserv = @default_options[:memcache_server]
        mopts = @default_options.
          reject{|k,v| !MemCache::DEFAULT_OPTIONS.include? k }
        @pool = MemCache.new mserv, mopts
        unless @pool.active? and @pool.servers.any?{|c| c.alive? }
          raise 'No memcache servers'
        end
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.get(sid, true)
        end
      end

      def get_session(env, session_id)
        @mutex.lock if env['rack.multithread']
        unless session_id and session = @pool.get(session_id)
          session_id, session = generate_sid, {}
          unless /^STORED/ =~ @pool.add(session_id, session)
            raise "Session collision on '#{session_id.inspect}'"
          end
        end
        session.instance_variable_set '@old', @pool.get(session_id, true)
        return [session_id, session]
      rescue MemCache::MemCacheError, Errno::ECONNREFUSED
        # MemCache server cannot be contacted
        warn "#{self} is unable to find memcached server."
        warn $!.inspect
        return [ nil, {} ]
      ensure
        @mutex.unlock if @mutex.locked?
      end

      def set_session(env, session_id, new_session, options)
        expiry = options[:expire_after]
        expiry = expiry.nil? ? 0 : expiry + 1

        @mutex.lock if env['rack.multithread']
        if options[:renew] or options[:drop]
          @pool.delete session_id
          return false if options[:drop]
          session_id = generate_sid
          @pool.add session_id, {} # so we don't worry about cache miss on #set
        end

        session = @pool.get(session_id) || {}
        old_session = new_session.instance_variable_get '@old'
        old_session = old_session ? Marshal.load(old_session) : {}

        unless Hash === old_session and Hash === new_session
          env['rack.errors'].
            puts 'Bad old_session or new_session sessions provided.'
        else # merge sessions
          # alterations are either update or delete, making as few changes as
          # possible to prevent possible issues.

          # removed keys
          delete = old_session.keys - new_session.keys
          if $VERBOSE and not delete.empty?
            env['rack.errors'].
              puts "//@#{session_id}: delete #{delete*','}"
          end
          delete.each{|k| session.delete k }

          # added or altered keys
          update = new_session.keys.
            select{|k| new_session[k] != old_session[k] }
          if $VERBOSE and not update.empty?
            env['rack.errors'].puts "//@#{session_id}: update #{update*','}"
          end
          update.each{|k| session[k] = new_session[k] }
        end

        @pool.set session_id, session, expiry
        return session_id
      rescue MemCache::MemCacheError, Errno::ECONNREFUSED
        # MemCache server cannot be contacted
        warn "#{self} is unable to find memcached server."
        warn $!.inspect
        return false
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end

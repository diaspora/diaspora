# encoding: utf-8

module Warden
  class UserNotSet < RuntimeError; end

  class Proxy
    # An accessor to the winning strategy
    # :api: private
    attr_accessor :winning_strategy

    # An accessor to the rack env hash, the proxy owner and its config
    # :api: public
    attr_reader :env, :manager, :config, :winning_strategies

    extend ::Forwardable
    include ::Warden::Mixins::Common

    # :api: private
    def_delegators :winning_strategy, :headers, :status, :custom_response

    # :api: public
    def_delegators :config, :default_strategies

    def initialize(env, manager) #:nodoc:
      @env, @users, @winning_strategies = env, {}, {}
      @manager, @config = manager, manager.config.dup
      @strategies = Hash.new { |h,k| h[k] = {} }
      errors # setup the error object in the session
      manager._run_callbacks(:on_request, self)
    end

    # Points to a SessionSerializer instance responsible for handling
    # everything related with storing, fetching and removing the user
    # session.
    # :api: public
    def session_serializer
      @session_serializer ||= Warden::SessionSerializer.new(@env)
    end

    # Clear the cache of performed strategies so far. It has the same API
    # as authenticate, allowing you to clear an specific strategies for
    # given scope:
    #
    # Parameters:
    #   args - a list of symbols (labels) that name the strategies to attempt
    #   opts - an options hash that contains the :scope of the user to check
    #
    # Example:
    #   # Clear all strategies for the configured default_scope
    #   env['warden'].clear_strategies_cache!
    #
    #   # Clear all strategies for the :admin scope
    #   env['warden'].clear_strategies_cache!(:scope => :admin)
    #
    #   # Clear password strategy for the :admin scope
    #   env['warden'].clear_strategies_cache!(:password, :scope => :admin)
    #
    # :api: public
    def clear_strategies_cache!(*args)
      scope, opts = _retrieve_scope_and_opts(args)

      @winning_strategies.delete(scope)
      @strategies[scope].each do |k, v|
        v.clear! if args.empty? || args.include?(k)
      end
    end

    # Run the authentiation strategies for the given strategies.
    # If there is already a user logged in for a given scope, the strategies are not run
    # This does not halt the flow of control and is a passive attempt to authenticate only
    # When scope is not specified, the default_scope is assumed.
    #
    # Parameters:
    #   args - a list of symbols (labels) that name the strategies to attempt
    #   opts - an options hash that contains the :scope of the user to check
    #
    # Example:
    #   env['warden'].authenticate(:password, :basic, :scope => :sudo)
    #
    # :api: public
    def authenticate(*args)
      user, opts = _perform_authentication(*args)
      user
    end

    # Same API as authenticated, but returns a boolean instead of a user.
    # The difference between this method (authenticate?) and authenticated?
    # is that the former will run strategies if the user has not yet been authenticated,
    # and the second relies on already performed ones.
    # :api: public
    def authenticate?(*args)
      result = !!authenticate(*args)
      yield if result && block_given?
      result
    end

    # The same as +authenticate+ except on failure it will throw an :warden symbol causing the request to be halted
    # and rendered through the +failure_app+
    #
    # Example
    #   env['warden'].authenticate!(:password, :scope => :publisher) # throws if it cannot authenticate
    #
    # :api: public
    def authenticate!(*args)
      user, opts = _perform_authentication(*args)
      throw(:warden, opts) unless user
      user
    end

    # Check to see if there is an authenticated user for the given scope.
    # This brings the user from the session, but does not run strategies before doing so.
    # If you want strategies to be run, please check authenticate?.
    #
    # Parameters:
    #   scope - the scope to check for authentication. Defaults to default_scope
    #
    # Example:
    #   env['warden'].authenticated?(:admin)
    #
    # :api: public
    def authenticated?(scope = @config.default_scope)
      result = !!user(scope)
      yield if block_given? && result
      result
    end

    # Same API as authenticated?, but returns false when authenticated.
    # :api: public
    def unauthenticated?(scope = @config.default_scope)
      result = !authenticated?(scope)
      yield if block_given? && result
      result
    end

    # Manually set the user into the session and auth proxy
    #
    # Parameters:
    #   user - An object that has been setup to serialize into and out of the session.
    #   opts - An options hash.  Use the :scope option to set the scope of the user, set the :store option to false to skip serializing into the session.
    #
    # :api: public
    def set_user(user, opts = {})
      return unless user
      scope = (opts[:scope] ||= @config.default_scope)

      # Get the default options from the master configuration for the given scope
      opts = @config.scope_defaults(scope).merge(opts)

      @users[scope] = user
      session_serializer.store(user, scope) unless opts[:store] == false

      opts[:event] ||= :set_user
      manager._run_callbacks(:after_set_user, user, self, opts)
      @users[scope]
    end

    # Provides acccess to the user object in a given scope for a request.
    # Will be nil if not logged in. Please notice that this method does not
    # perform strategies.
    #
    # Example:
    #   # without scope (default user)
    #   env['warden'].user
    #
    #   # with scope
    #   env['warden'].user(:admin)
    #
    # :api: public
    def user(scope = @config.default_scope)
      @users[scope] ||= set_user(session_serializer.fetch(scope),
                                 :scope => scope, :event => :fetch)
    end

    # Provides a scoped session data for authenticated users.
    # Warden manages clearing out this data when a user logs out
    #
    # Example
    #  # default scope
    #  env['warden'].session[:foo] = "bar"
    #
    #  # :sudo scope
    #  env['warden'].session(:sudo)[:foo] = "bar"
    #
    # :api: public
    def session(scope = @config.default_scope)
      raise NotAuthenticated, "#{scope.inspect} user is not logged in" unless authenticated?(scope)
      raw_session["warden.user.#{scope}.session"] ||= {}
    end

    # Provides logout functionality.
    # The logout also manages any authenticated data storage and clears it when a user logs out.
    #
    # Parameters:
    #   scopes - a list of scopes to logout
    #
    # Example:
    #  # Logout everyone and clear the session
    #  env['warden'].logout
    #
    #  # Logout the default user but leave the rest of the session alone
    #  env['warden'].logout(:default)
    #
    #  # Logout the :publisher and :admin user
    #  env['warden'].logout(:publisher, :admin)
    #
    # :api: public
    def logout(*scopes)
      if scopes.empty?
        scopes = @users.keys
        reset_session = true
      end

      scopes.each do |scope|
        user = @users.delete(scope)
        manager._run_callbacks(:before_logout, user, self, :scope => scope)

        raw_session.delete("warden.user.#{scope}.session")
        session_serializer.delete(scope, user)
      end

      reset_session! if reset_session
    end

    # proxy methods through to the winning strategy
    # :api: private
    def result # :nodoc:
      winning_strategy && winning_strategy.result
    end

    # Proxy through to the authentication strategy to find out the message that was generated.
    # :api: public
    def message
      winning_strategy && winning_strategy.message
    end

    # Provides a way to return a 401 without warden defering to the failure app
    # The result is a direct passthrough of your own response
    # :api: public
    def custom_failure!
      @custom_failure = true
    end

    # Check to see if the custom failur flag has been set
    # :api: public
    def custom_failure?
      !!@custom_failure
    end

    private

    def _perform_authentication(*args)
      scope, opts = _retrieve_scope_and_opts(args)
      user = nil

      # Look for an existing user in the session for this scope.
      # If there was no user in the session. See if we can get one from the request.
      return user, opts if user = user(scope)
      _run_strategies_for(scope, args)

      if winning_strategy && winning_strategy.user
        set_user(winning_strategy.user, opts.merge!(:event => :authentication))
      end

      [@users[scope], opts]
    end

    def _retrieve_scope_and_opts(args) #:nodoc:
      opts  = args.last.is_a?(Hash) ? args.pop : {}
      scope = opts[:scope] || @config.default_scope
      opts  = (config[:scope_defaults][scope] || {}).merge(opts)
      [scope, opts]
    end

    # Run the strategies for a given scope
    def _run_strategies_for(scope, args) #:nodoc:
      self.winning_strategy = @winning_strategies[scope]
      return if winning_strategy && winning_strategy.halted?

      strategies = args.empty? ? default_strategies(:scope => scope) : args

      strategies.each do |name|
        strategy = _fetch_strategy(name, scope)
        next unless strategy && !strategy.performed? && strategy.valid?

        self.winning_strategy = @winning_strategies[scope] = strategy
        strategy._run!
        break if strategy.halted?
      end
    end

    # Fetchs strategies and keep them in a hash cache.
    def _fetch_strategy(name, scope)
      return @strategies[scope][name] if @strategies[scope].key?(name)

      @strategies[scope][name] = if klass = Warden::Strategies[name]
        klass.new(@env, scope)
      elsif @config.silence_missing_strategies?
        nil
      else
        raise "Invalid strategy #{name}"
      end
    end

  end # Proxy
end # Warden

# encoding: utf-8
module Warden
  class SessionSerializer
    attr_reader :env
    include ::Warden::Mixins::Common

    def initialize(env)
      @env = env
    end

    def key_for(scope)
      "warden.user.#{scope}.key"
    end

    def serialize(user)
      user
    end

    def deserialize(key)
      key
    end

    def store(user, scope)
      return unless user
      session[key_for(scope)] = serialize(user)
    end

    def fetch(scope)
      key = session[key_for(scope)]
      return nil unless key
      user = deserialize(key)
      delete(scope) unless user
      user
    end

    def stored?(scope)
      !!session[key_for(scope)]
    end

    def delete(scope, user=nil)
      session.delete(key_for(scope))
    end
  end # SessionSerializer
end # Warden
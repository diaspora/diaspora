# frozen_string_literal: true

module Export
  # This is a serializer for the user's own posts
  class OwnPostSerializer < FederationEntitySerializer
    # Only for public posts.
    # Includes URIs of pods which must be notified on the post updates.
    # Must always include local pod URI since we will want all the updates on the post if user migrates.
    has_many :subscribed_pods_uris

    # Only for private posts.
    # Includes diaspora* IDs of people who must be notified on post updates.
    has_many :subscribed_users_ids

    # Normally accepts Post as an object.
    def initialize(*)
      super
      self.except = [excluded_subscription_key]
    end

    private

    def subscribed_pods_uris
      object.subscribed_pods_uris.push(AppConfig.pod_uri.to_s)
    end

    def subscribed_users_ids
      object.subscribers.map(&:diaspora_handle)
    end

    def excluded_subscription_key
      object.public? ? :subscribed_users_ids : :subscribed_pods_uris
    end
  end
end

# frozen_string_literal: true

module Export
  class UserSerializer < ActiveModel::Serializer
    attributes :username,
               :email,
               :language,
               :private_key,
               :disable_mail,
               :show_community_spotlight_in_stream,
               :auto_follow_back,
               :auto_follow_back_aspect,
               :strip_exif
    has_one    :profile, serializer: FederationEntitySerializer
    has_many   :contact_groups, each_serializer: Export::AspectSerializer
    has_many   :contacts, each_serializer: Export::ContactSerializer
    has_many   :posts,    each_serializer: Export::OwnPostSerializer
    has_many   :followed_tags
    has_many   :post_subscriptions

    has_many :relayables, serializer: FlatMapArraySerializer, each_serializer: Export::OwnRelayablesSerializer

    def initialize(user_id, options={})
      @user_id = user_id
      super(object, options)
    end

    private

    def object
      User.find(@user_id)
    end

    def posts
      object.posts.find_each(batch_size: 20)
    end

    def contacts
      object.contacts.find_each(batch_size: 100)
    end

    def relayables
      [comments, likes, poll_participations].map {|relayable|
        relayable.find_each(batch_size: 20)
      }
    end

    %i[comments likes poll_participations].each {|collection|
      delegate collection, to: :person
    }

    delegate :person, to: :object

    def contact_groups
      object.aspects
    end

    def private_key
      object.serialized_private_key
    end

    def followed_tags
      object.followed_tags.map(&:name)
    end

    def post_subscriptions
      Post.subscribed_by(object).pluck(:guid)
    end

    # Avoid calling pointless #embedded_in_root_associations method
    def serializable_data
      {}
    end
  end
end

# A user can subscribe to certain channels in order to receive email notifications
# when a post is created in that channel. The subscribing user is called subscriber.
#
# ## Channel
#
# The channel is polymorphic such that the subscriber can subscribe to several types
# of objects.
#
# * `Person`: Receive notifications whenever the person creates a post.
# * `Aspect`: Receive notifications whenever anyone of the aspect's members creates a post.
# * `Tag`: Receive notifications whenever a post is created with that tag.
#
class Subscription < ActiveRecord::Base
  belongs_to :subscriber, class_name: "User"
  belongs_to :channel, polymorphic: true

  # When a new post is created, it's convenient to get all subscriptions
  # that should be triggered by the new post. This includes:
  #
  # - Person-type channels, considering the author of the post.
  # - Aspect-type channels, considering the author could be member of the aspect.
  # - Tag-type channels, considering the post could have the tag.
  #
  def self.by_post(post)
    (by_person(post.author) +
    by_aspects(Aspect.includes(:contacts).where(contacts: {person: post.author})) +
    by_tags(post.tags)).select {|subscription|
      # Check that the post is actually visible to the subscriber:
      post.share_visibilities.includes(:contact)
      .where(contacts: {user_id: subscription.subscriber_id})
      .any?
    }
  end

  def self.by_person(person)
    where(channel_type: "Person", channel_id: person.id)
  end

  def self.by_aspects(aspects)
    aspects.map {|aspect| by_aspect(aspect) }.flatten
  end

  def self.by_aspect(aspect)
    where(channel_type: "Aspect", channel_id: aspect.id)
  end

  def self.by_tags(tags)
    tags.map {|tag| by_tag(tag) }.flatten
  end

  def self.by_tag(tag)
    where(channel_type: "ActsAsTaggableOn::Tag", channel_id: tag.id)
  end
end

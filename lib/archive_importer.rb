# frozen_string_literal: true

class ArchiveImporter
  include ArchiveHelper
  include Diaspora::Logging

  attr_accessor :user

  def initialize(archive_hash)
    @archive_hash = archive_hash
  end

  def import
    import_tag_followings
    import_aspects
    import_contacts
    import_posts
    import_relayables
    import_subscriptions
    import_others_relayables
  end

  def create_user(attr)
    allowed_keys = %w[
      email strip_exif show_community_spotlight_in_stream language disable_mail auto_follow_back
    ]
    data = convert_keys(archive_hash["user"], allowed_keys)
    # setting getting_started to false as the user doesn't need to see the getting started wizard
    data.merge!(
      username:              attr[:username],
      password:              attr[:password],
      password_confirmation: attr[:password],
      getting_started:       false,
      person:                {
        profile_attributes: profile_attributes
      }
    )
    self.user = User.build(data)
    user.save!
  end

  private

  attr_reader :archive_hash

  def profile_attributes
    allowed_keys = %w[first_name last_name image_url bio gender location birthday searchable nsfw tag_string]
    profile_data = archive_hash["user"]["profile"]["entity_data"]
    convert_keys(profile_data, allowed_keys).tap do |attrs|
      attrs[:public_details] = profile_data["public"]
    end
  end

  def import_contacts
    import_collection(contacts, ContactImporter)
  end

  def set_auto_follow_back_aspect
    name = archive_hash["user"]["auto_follow_back_aspect"]
    return if name.nil?

    aspect = user.aspects.find_by(name: name)
    user.update(auto_follow_back_aspect: aspect) if aspect
  end

  def import_aspects
    contact_groups.each do |group|
      begin
        user.aspects.create!(group.slice("name"))
      rescue ActiveRecord::RecordInvalid => e
        logger.warn "#{self}: #{e}"
      end
    end
    set_auto_follow_back_aspect
  end

  def import_posts
    import_collection(posts, PostImporter)
  end

  def import_relayables
    import_collection(relayables, OwnRelayableImporter)
  end

  def import_others_relayables
    import_collection(others_relayables, EntityImporter)
  end

  def import_collection(collection, importer_class)
    collection.each do |object|
      importer_class.new(object, user).import
    end
  end

  def import_tag_followings
    archive_hash.fetch("user").fetch("followed_tags", []).each do |tag_name|
      begin
        tag = ActsAsTaggableOn::Tag.find_or_create_by(name: tag_name)
        user.tag_followings.create!(tag: tag)
      rescue ActiveRecord::RecordInvalid => e
        logger.warn "#{self}: #{e}"
      end
    end
  end

  def import_subscriptions
    post_subscriptions.each do |post_guid|
      post = Post.find_or_fetch_by(archive_author_diaspora_id, post_guid)
      if post.nil?
        logger.warn "#{self}: post with guid #{post_guid} not found, can't subscribe"
        next
      end
      begin
        user.participations.create!(target: post)
      rescue ActiveRecord::RecordInvalid => e
        logger.warn "#{self}: #{e}"
      end
    end
  end

  def convert_keys(hash, allowed_keys)
    hash
      .slice(*allowed_keys)
      .symbolize_keys
  end

  def to_s
    "#{self.class}:#{archive_author_diaspora_id}:#{user.diaspora_handle}"
  end
end

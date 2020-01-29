# frozen_string_literal: true

class TagFollowingService
  def initialize(user=nil)
    @user = user
  end

  def create(name)
    name_normalized = ActsAsTaggableOn::Tag.normalize(name)
    raise ArgumentError, "Name field null or empty" if name_normalized.blank?

    tag = ActsAsTaggableOn::Tag.find_or_create_by(name: name_normalized)
    raise DuplicateTag if @user.tag_followings.exists?(tag_id: tag.id)

    tag_following = @user.tag_followings.new(tag_id: tag.id)
    raise "Can't process tag entity" unless tag_following.save

    tag
  end

  def find(name)
    name_normalized = ActsAsTaggableOn::Tag.normalize(name)
    ActsAsTaggableOn::Tag.find_or_create_by(name: name_normalized)
  end

  def destroy(id)
    tag_following = @user.tag_followings.find_by!(tag_id: id)
    tag_following.destroy
  end

  def destroy_by_name(name)
    name_normalized = ActsAsTaggableOn::Tag.normalize(name)
    followed_tag = @user.followed_tags.find_by!(name: name_normalized)
    destroy(followed_tag.id)
  end

  def index
    @user.followed_tags
  end

  class DuplicateTag < RuntimeError; end
end

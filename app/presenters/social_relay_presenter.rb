# frozen_string_literal: true

class SocialRelayPresenter
  def as_json(*)
    {
      "subscribe" => AppConfig.relay.inbound.subscribe?,
      "scope"     => AppConfig.relay.inbound.scope,
      "tags"      => tags
    }
  end

  def tags
    return [] unless AppConfig.relay.inbound.scope == "tags"
    tags = AppConfig.relay.inbound.pod_tags.present? ? AppConfig.relay.inbound.pod_tags.split(",").map(&:strip) : []
    add_user_tags(tags)
    tags.uniq
  end

  def add_user_tags(tags)
    if AppConfig.relay.inbound.include_user_tags?
      user_ids = User.halfyear_actives.pluck(:id)
      tag_ids = TagFollowing.where(user: user_ids).select(:tag_id).distinct.pluck(:tag_id)
      tags.concat ActsAsTaggableOn::Tag.where(id: tag_ids).pluck(:name)
    end
  end
end

# frozen_string_literal: true

class Stream::Multi < Stream::Base

  # @return [String] URL
  def link(opts)
    Rails.application.routes.url_helpers.stream_path(opts)
  end

  # @return [String]
  def title
    I18n.t('streams.multi.title')
  end

  def posts
    @posts ||= ::EvilQuery::MultiStream.new(user, order, max_time, include_community_spotlight?).make_relation!
  end

  #emits an enum of the groups which the post appeared
  # :spotlight, :aspects, :tags, :mentioned
  def post_from_group(post)
    streams_included.collect do |source|
      is_in?(source, post)
    end.compact
  end

  private

  def publisher_opts
    if welcome?
      {open: true, prefill: publisher_prefill, public: true}
    else
      {public: user.post_default_public}
    end
  end

  # Generates the prefill for the publisher
  #
  # @return [String]
  def publisher_prefill
    prefill = I18n.t("shared.publisher.new_user_prefill.hello", :new_user_tag => I18n.t('shared.publisher.new_user_prefill.newhere'))
    if self.user.followed_tags.size > 0
      tag_string = self.user.followed_tags.map{|t| "##{t.name}"}.to_sentence
      prefill << I18n.t("shared.publisher.new_user_prefill.i_like", :tags => tag_string)
    end

    if inviter = self.user.invited_by.try(:person)
      prefill << I18n.t("shared.publisher.new_user_prefill.invited_by")
      prefill << "@{#{inviter.diaspora_handle}}!"
    end

    prefill
  end

  # @return [Boolean]
  def welcome?
    self.user.getting_started
  end

  # @return [Array<Symbol>]
  def streams_included
    @streams_included ||= lambda do
      array = [:mentioned, :aspects, :followed_tags]
      array << :community_spotlight if include_community_spotlight?
      array
    end.call
  end

  # @return [Symbol]
  def is_in?(sym, post)
    if self.send("#{sym.to_s}_post_ids").find{|x| (x == post.id) || (x.to_s == post.id.to_s)}
      "#{sym.to_s}_stream".to_sym
    end
  end

  # @return [Boolean]
  def include_community_spotlight?
    AppConfig.settings.community_spotlight.enable? && user.show_community_spotlight_in_stream?
  end
end

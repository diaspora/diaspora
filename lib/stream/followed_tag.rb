# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::FollowedTag < Stream::Base

  def link(opts={})
    Rails.application.routes.url_helpers.tag_followings_path(opts)
  end

  def title
    I18n.t('streams.followed_tag.title')
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    if tag_ids.empty?
      @posts = StatusMessage.none
    else
      @posts ||= StatusMessage.any_user_tag_stream(user, tag_ids)
    end
    @posts
  end

  private

  def tag_string
    @tag_string ||= tags.join(', '){|tag| tag.name}.to_s
  end

  def tag_ids
    tags.map{|x| x.id}
  end

  def tags
    @tags = user.followed_tags
  end
end

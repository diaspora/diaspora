#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::FollowedTag < Stream::Base

  def link(opts={})
    Rails.application.routes.url_helpers.tag_followings_path(opts)
  end

  def title
    I18n.t('aspects.index.tags_following')
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    return [] if tag_string.empty?
    @posts ||= StatusMessage.tag_stream(user, tag_array, max_time, order)
  end

  def contacts_title
    I18n.translate('streams.tags.contacts_title')
  end



  private

  def tag_string
    @tag_string ||= tags.join(', '){|tag| tag.name}.to_s
  end

  def tag_array
    tags.map{|x| x.name}
  end

  def tags
    @tags = user.followed_tags
  end
end

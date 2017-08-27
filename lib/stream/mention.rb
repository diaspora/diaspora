# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Mention < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.mentions_path(opts)
  end

  def title
    I18n.translate("streams.mentions.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= StatusMessage.where_person_is_mentioned(self.user.person)
  end
end

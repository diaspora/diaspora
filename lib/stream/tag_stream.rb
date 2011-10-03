#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagStream < BaseStream

  def link(opts={})
    Rails.application.routes.url_helpers.tag_followings_path(opts)
  end

  def title
    tags_titleized
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    if tag_string.empty?
      []
    else
      @posts ||= StatusMessage.owned_or_visible_by_user(user).
        tagged_with([tag_string], :any => true).
        where(:public => true).
        for_a_stream(@max_time, @order)
    end
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= posts.map{|p| p.author}.uniq 
  end

  def contacts_title
    I18n.translate('streams.tags.contacts_title')
  end

  private

  def tag_string
    @tag_string ||= tags.join(', '){|tag| tag.name}.to_s
  end

  def tags
    @tags = user.followed_tags
  end

  def tags_titleized
    tag_string.split(',').map{|x| "##{x.strip}"}.to_sentence
  end
end

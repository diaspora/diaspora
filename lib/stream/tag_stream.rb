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
    return [] if tag_string.empty?
    @posts ||= StatusMessage.owned_or_visible_by_user(user).
                joins(:tags).where(:tags => {:name => tag_array}).
                for_a_stream(@max_time, @order)
  end

  def people
    @people ||= posts.map{|p| p.author}.uniq 
  end

  def contacts_title
    I18n.translate('streams.tags.contacts_title')
  end

  def can_comment_on?(post)
    @can_comment_cache ||= {}
    @can_comment_cache[post.id] ||= contacts_in_stream.find{|contact| contact.person_id == post.author.id}.present?
    @can_comment_cache[post.id]
  end

  def contacts_in_stream
    @contacts_in_stream ||= Contact.where(:user => user, :person => people).all
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

  def tags_titleized
    tag_string.split(',').map{|x| "##{x.strip}"}.to_sentence
  end
end

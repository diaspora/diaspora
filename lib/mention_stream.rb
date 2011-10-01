#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class MentionStream< BaseStream


  # @param user [User]
  # @param inputted_aspect_ids [Array<Integer>] Ids of aspects for given stream
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]

  def link(opts={})
    Rails.application.routes.url_helpers.mentions_path(opts)
  end

  def title
    I18n.translate("streams.mentions.title")
  end


  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= StatusMessage.where_person_is_mentioned(self.user.person).for_a_stream(max_time, order)
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= posts.map{|p| p.author}.uniq 
  end

  def contacts_title
    I18n.translate('streams.mentions.contacts_title')
  end
end

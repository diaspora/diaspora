#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class MentionStream

  attr_reader :max_time, :order

  # @param user [User]
  # @param inputted_aspect_ids [Array<Integer>] Ids of aspects for given stream
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]
  def initialize(user, opts={})
    @user = user
    set_max_time(opts[:max_time])

    @order = opts[:order] || 'created_at'
  end

  def set_max_time(time_string)
    @max_time = Time.at(time_string.to_i) unless time_string.blank?
    @max_time ||= (Time.now + 1)
  end

  def link(opts={})
    Rails.application.routes.url_helpers.mentions_path(opts)
  end

  def title
    "Your Mentions"
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= Post.joins(:mentions).where(:mentions => {:person_id => @user.person.id}).for_a_stream(@max_time, @order)
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= posts.map{|p| p.author}.uniq 
  end

  def for_all_aspects?
    false
  end
  
  def ajax_posts?
    false
  end
  
  def aspects
    []
  end

  def aspect
    nil
  end

  def contacts_title
    "People who mentioned you"
  end
  
  def contacts_link
    '#'
  end
  
  def aspect_ids
    []
  end
end

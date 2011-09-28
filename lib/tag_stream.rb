#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagStream 

  attr_reader :max_time, :order

  # @param user [User]
  # @param inputted_aspect_ids [Array<Integer>] Ids of aspects for given stream
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]
  def initialize(user, opts={})
    @tags = user.followed_tags
    @tag_string = @tags.join(', '){|tag| tag.name}
    @user = user
    @max_time = opts[:max_time]
    @order = opts[:order]
  end

  def link(opts={})
    Rails.application.routes.url_helpers.tag_followings_path(opts)
  end

  def title
    "Tag Stream"
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= StatusMessage.tagged_with([@tag_string], :any => true)
             
          
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= posts.map{|p| p.author}.uniq 
  end

  def for_all_aspects?
    false
  end
  
  def aspects
    []
  end

  def aspect
    nil
  end

  def contacts_title
    "People who like #{@tag_string}"
  end
  
  def aspect_ids
    []
  end

end

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Tag < Stream::Base
  attr_accessor :tag_name, :people_page

  def initialize(user, tag_name, opts={})
    self.tag_name = tag_name
    self.people_page = opts[:page] || 1
    super(user, opts)
  end

  def tag
    @tag ||= ActsAsTaggableOn::Tag.find_by_name(tag_name)
  end

  def tag_follow_count
    @tag_follow_count ||= tag.try(:followed_count).to_i
  end

  def display_tag_name
    @display_tag_name ||= "##{tag_name}"
  end

  def tagged_people
    @people ||= Person.profile_tagged_with(tag_name).paginate(:page => people_page, :per_page => 15)
  end

  def tagged_people_count
    @people_count ||= Person.profile_tagged_with(tag_name).count
  end

  def posts
    @posts ||= construct_post_query
  end

  def tag_name=(tag_name)
    @tag_name = tag_name.downcase.gsub('#', '')
  end

  private
  # @return [Hash]
  def publisher_opts
    {:prefill => "#{display_tag_name} "}
  end

  def construct_post_query
    posts = StatusMessage
    if user.present? 
      posts = posts.owned_or_visible_by_user(user)
    else
      posts = posts.all_public
    end
    posts.tagged_with(tag_name).for_a_stream(max_time, 'created_at')
  end
end

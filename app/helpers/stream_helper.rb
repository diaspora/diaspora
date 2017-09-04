# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper
  def next_page_path(opts ={})
    if controller.instance_of?(TagsController)
      tag_path(:name => @stream.tag_name, :max_time => time_for_scroll(@stream))
    elsif controller.instance_of?(PeopleController)
      local_or_remote_person_path(@person, :max_time => time_for_scroll(@stream))
    elsif controller.instance_of?(StreamsController)
      next_stream_path
    else
      raise 'in order to use pagination for this new controller, update next_page_path in stream helper'
    end
  end

  def reshare?(post)
    post.instance_of?(Reshare)
  end

  private

  def next_stream_path
    if current_page?(:stream)
      stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:activity_stream)
      activity_stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:aspects_stream)
      aspects_stream_path(max_time: time_for_scroll(@stream), a_ids: session[:a_ids])
    elsif current_page?(:public_stream)
      public_stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:commented_stream)
      commented_stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:liked_stream)
      liked_stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:mentioned_stream)
      mentioned_stream_path(max_time: time_for_scroll(@stream))
    elsif current_page?(:followed_tags_stream)
      followed_tags_stream_path(max_time: time_for_scroll(@stream))
    else
      raise "in order to use pagination for this new stream, update next_stream_path in stream helper"
    end
  end

  def time_for_scroll(stream)
    if stream.stream_posts.empty?
      (Time.now() + 1).to_i
    else
      stream.stream_posts.last.send(stream.order.to_sym).to_i
    end
  end
end

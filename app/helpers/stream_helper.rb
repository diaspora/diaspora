#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper
  def next_page_path(opts ={})
    if controller.instance_of?(TagsController)
      tag_path(:name => @stream.tag_name, :max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(AppsController)
      "/apps/1?#{{:max_time => @posts.last.created_at.to_i}.to_param}"
    elsif controller.instance_of?(PeopleController)
      local_or_remote_person_path(@person, :max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(TagFollowingsController)
      tag_followings_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(CommunitySpotlightController)
      spotlight_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(MentionsController)
      mentions_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(MultisController)
      multi_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(PostsController)
      public_stream_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(AspectsController)
      aspects_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream), :a_ids => @stream.aspect_ids)
    elsif controller.instance_of?(LikeStreamController)
      like_stream_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    elsif controller.instance_of?(CommentStreamController)
      comment_stream_path(:max_time => time_for_scroll(opts[:ajax_stream], @stream))
    else
      raise 'in order to use pagination for this new controller, update next_page_path in stream helper'
    end
  end

  def time_for_scroll(ajax_stream, stream)
    if ajax_stream || stream.stream_posts.empty?
      (Time.now() + 1).to_i
    else
      stream.stream_posts.last.send(stream.order.to_sym).to_i
    end
  end

  def reshare?(post)
    post.instance_of?(Reshare)
  end
end

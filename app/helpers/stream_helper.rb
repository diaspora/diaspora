#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper
  def next_page_path(opts ={})
    if controller.instance_of?(TagsController)
      tag_path(@tag, :max_time => @posts.last.created_at.to_i)
    elsif controller.instance_of?(AppsController)
      "/apps/1?#{{:max_time => @posts.last.created_at.to_i}.to_param}"
    elsif controller.instance_of?(PeopleController)
      person_path(@person, :max_time => @posts.last.created_at.to_i)
    elsif controller.instance_of?(TagFollowingsController) 
      tag_followings_path(:max_time => @stream.posts.last.created_at.to_i)
    elsif controller.instance_of?(AspectsController)
     if opts[:ajax_stream] 
       time = (Time.now() + 1).to_i

     else
       time = @stream.posts.last.send(@stream.order.to_sym).to_i
     end
      aspects_path(:max_time => time, :sort_order => session[:sort_order], :a_ids => @stream.aspect_ids)
    else
      raise 'in order to use pagination for this new controller, update next_page_path in stream helper'
    end
  end

  def time_for_sort post
    if controller.instance_of?(AspectsController)
      post.send(session[:sort_order].to_sym)
    else
      post.created_at
    end
  end

  def comments_expanded
    false
  end

  def reshare?(post)
    post.instance_of?(Reshare)
  end
end

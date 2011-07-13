#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper
  def next_page_path
    if controller.instance_of?(TagsController)
      tag_path(@tag, :max_time => @posts.last.created_at.to_i)
    elsif controller.instance_of?(AppsController)
      "/apps/1?#{{:max_time => @posts.last.created_at.to_i}.to_param}"
    elsif controller.instance_of?(PeopleController)
      person_path(@person, :max_time => @posts.last.created_at.to_i)
    elsif controller.instance_of?(AspectsController)
      aspects_path(:max_time => @posts.last.send(session[:sort_order].to_sym).to_i, :a_ids => params[:a_ids])
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
    (defined?(post.model) && post.model.is_a?(Reshare)) || post.instance_of?(Reshare)
  end
end

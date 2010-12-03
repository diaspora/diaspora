#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  skip_before_filter :set_contacts_and_status
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :set_locale

  def show
    @post = Post.first(:id => params[:id], :public => true)
    @landing_page = true
    if @post
      render "posts/#{@post.class.to_s.underscore}", :layout => true
    else
      flash[:error] = "that post does not exsist!"
      redirect_to root_url
    end    
  end
end

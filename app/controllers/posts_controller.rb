#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  skip_before_filter :set_contacts_notifications_and_status
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :set_locale
  skip_before_filter :which_action_and_user

  def show
    @post = Post.where(:id => params[:id], :public => true).includes(:person, :comments => :person).first

    if @post
      @landing_page = true
      @person = @post.person
      if @person.owner_id
        I18n.locale = @person.owner.language
        render "posts/#{@post.class.to_s.underscore}", :layout => true
      else
        flash[:error] = "that post does not exsist!"
        redirect_to root_url
      end
    else
      flash[:error] = "that post does not exsist!"
      redirect_to root_url
    end
  end
end

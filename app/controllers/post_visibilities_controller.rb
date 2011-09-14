#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class PostVisibilitiesController < ApplicationController
  before_filter :authenticate_user!

  def update
    #note :id references a postvisibility

    @post = Post.where(:id => params[:post_id]).select("id, guid, author_id").first
    @contact = current_user.contact_for(@post.author)

    if @contact && @vis = PostVisibility.where(:contact_id => @contact.id,
                                               :post_id => params[:post_id]).first
      @vis.hidden = !@vis.hidden 
      if @vis.save
        render 'update'
        return
      end
    end
    render :nothing => true, :status => 403
  end
end

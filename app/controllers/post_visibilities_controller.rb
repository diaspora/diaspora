#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class PostVisibilitiesController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    #note :id is garbage

    @post = Post.where(:id => params[:post_id]).select("id, author_id").first
    @contact = current_user.contact_for( @post.author)
    @vis = PostVisibility.where(:contact_id => @contact.id,
                                :post_id => params[:post_id]).first
    if @vis
      @vis.hidden = true
      if @vis.save
        render :nothing => true, :status => 200
        return
      end
    end
    render :nothing => true, :status => 403
  end
end

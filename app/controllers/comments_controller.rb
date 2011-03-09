#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html, :mobile
  respond_to :json, :only => :show

  def create
    target = current_user.find_visible_post_by_id params[:post_id]
    text = params[:text]

    if target
      @comment = current_user.build_comment(text, :on => target)

      if @comment.save
        Rails.logger.info("event=create type=comment user=#{current_user.diaspora_handle} status=success comment=#{@comment.id} chars=#{params[:text].length}")
        Postzord::Dispatch.new(current_user, @comment).post

        respond_to do |format|
          format.js{
            json = { :post_id => @comment.post_id,
                                       :comment_id => @comment.id,
                                       :html => render_to_string(
                                         :partial => 'comments/comment',
                                         :locals => { :comment => @comment,
                                           :person => current_user.person,
                                          }
                                        )
                                      }
            render(:json => json, :status => 201)
          }
          format.html{ render :nothing => true, :status => 201 }
          format.mobile{ redirect_to status_message_path(@comment.post_id) }
        end
      else
        render :nothing => true, :status => 406
      end
    else
      render :nothing => true, :status => 406
    end
  end

end

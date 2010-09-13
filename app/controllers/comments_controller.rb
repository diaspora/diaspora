#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


class CommentsController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html
  respond_to :json, :only => :show

  def create
    target = Post.find_by_id params[:comment][:post_id]
    text = params[:comment][:text]

    @comment = current_user.comment text, :on => target
    render :nothing => true
  end

  def show
    @comment = Comment.find_by_id params[:id]
    respond_with @comment
  end

end

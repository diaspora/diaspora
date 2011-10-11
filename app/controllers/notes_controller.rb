#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'stream', 'note_stream')

class NotesController < ApplicationController
  before_filter :authenticate_user!

  def index
    aspect_ids = (params[:a_ids] ? params[:a_ids] : [])    
    @stream = NoteStream.new(current_user, aspect_ids,
                             :max_time => params[:max_time].to_i,
                             :order => sort_order)

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @stream.posts}
    else
      render 'aspects/index'
    end
  end
end

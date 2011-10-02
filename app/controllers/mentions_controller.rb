#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib','streams', 'mention_stream')

class MentionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_sort_order, :only => :index

  def index
    @stream = MentionStream.new(current_user, :max_time => params[:max_time], :order => sort_order)

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @stream.posts}
    else
      render 'aspects/index'
    end
  end
end

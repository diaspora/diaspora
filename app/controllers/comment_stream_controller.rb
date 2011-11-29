#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib','stream', 'comments')

class CommentStreamController < ApplicationController

  respond_to :html, :json

  def index
    @backbone = true

    respond_with do |format|
      format.html{ default_stream_action(Stream::Comments) }
      format.json{ render :json => stream(Stream::Comments).stream_posts.to_json(:include => {:author => {:include => :profile}}) }
    end
  end
end

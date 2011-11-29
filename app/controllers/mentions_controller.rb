#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib','stream', 'mention')

class MentionsController < ApplicationController

  respond_to :html, :json

  def index
    @backbone = true

    respond_with do |format|
      format.html{ default_stream_action(Stream::Mention) }
      format.json{ render :json => stream(Stream::Mention).stream_posts.to_json(:include => {:author => {:include => :profile}}) }
    end
  end
end

# Copyright (c) 2010-2011, Diaspora Inc. This file is
# licensed under the Affero General Public License version 3 or later. See
# the COPYRIGHT file.

require File.join(Rails.root, 'lib','stream', 'likes')

class LikeStreamController < ApplicationController

  respond_to :html, :json

  def index
    @backbone = true
    stream_klass = Stream::Likes

    respond_with do |format|
      format.html{ default_stream_action(stream_klass) }
      format.json{ stream_json(stream_klass) }
    end
  end
end

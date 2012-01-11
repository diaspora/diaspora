#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib','stream', 'comments')

class CommentStreamController < ApplicationController

  respond_to :html, :json

  def index
    stream_klass = Stream::Comments

    respond_with do |format|
      format.html{ default_stream_action(stream_klass) }
      format.json{ stream_json(stream_klass) }
    end
  end
end

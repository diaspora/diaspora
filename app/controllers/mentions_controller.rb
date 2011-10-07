#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib','stream', 'mention_stream')

class MentionsController < ApplicationController
  def index
    default_stream_action(MentionStream)
  end
end

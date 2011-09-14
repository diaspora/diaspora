#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublicsHelper
  def subscribe(opts = {})
    subscriber = Subscriber.first(:url => opts[:callback], :topic => opts[:topic])
    subscriber ||= Subscriber.new(:url => opts[:callback], :topic => opts[:topic])

    if subscriber.save
      if opts[:verify] == 'sync'
        204
      elsif opts[:verify] == 'async'
        202
      end
    else
      400
    end
  end

end

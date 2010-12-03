#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module MessageHandler

  NUM_TRIES = 3

  def self.add_post_request(destinations, body)
    b = CGI::escape( body )
    [*destinations].each do |dest|
      Resque.enqueue(Jobs::HttpPost, dest, body, NUM_TRIES)
    end
  end
end

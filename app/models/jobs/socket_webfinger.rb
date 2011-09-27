#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class SocketWebfinger < Base

    @queue = :socket_webfinger

    def self.perform(user_id, account, opts={})
      finger = Webfinger.new(account)
      begin
        result = finger.fetch
        result.socket_to_user(user_id, opts)
      rescue
        Diaspora::WebSocket.queue_to_user(user_id,
          {:class => 'people',
           :status => 'fail',
           :query => account,
           :response => I18n.t('people.webfinger.fail', :handle => account)}.to_json)
      end
    end
  end
end


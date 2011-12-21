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
        Diaspora::Websocket.to(user_id).socket(opts)
      rescue
        Diaspora::Websocket.to(user_id).socket(
          {:class => 'people',
           :status => 'fail',
           :query => account,
           :response => I18n.t('people.webfinger.fail', :handle => account)})
      end
    end
  end
end


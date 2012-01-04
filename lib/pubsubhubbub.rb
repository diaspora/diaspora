#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Pubsubhubbub
  H = {"User-Agent" => "PubSubHubbub Ruby", "Content-Type" => "application/x-www-form-urlencoded"}

  def initialize(hub, options={})
    @headers = H.merge(options[:head]) if options[:head]
    @hub = hub
  end

  def publish(feed)
    begin
      return RestClient.post(@hub, :headers => @headers, 'hub.url' => feed, 'hub.mode' => 'publish')
    rescue RestClient::BadRequest=> e
      Rails.logger.warn "Public URL for your users are incorrect.  (This is ok if you are in development and localhost is your pod_url) #{e.inspect}"
    rescue SocketError
      Rails.logger.warn "Pod not connected to the internet.  Cannot post to pubsub hub!"
    end
  end
end

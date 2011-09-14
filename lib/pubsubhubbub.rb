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
      response = RestClient.post(@hub, :headers => @headers, 'hub.url' => feed, 'hub.mode' => 'publish')
    return response
    rescue  RestClient::BadRequest=> e
      Rails.logger.warn "Public URL for your users are incorrect.  this is ok if you are in development and localhost is your pod_url#{e.inspect}" 
    end
  end
end

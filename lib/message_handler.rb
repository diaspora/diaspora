#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class MessageHandler

  NUM_TRIES = 3
  TIMEOUT = 5 #seconds

  def initialize
    @queue = EM::Queue.new
  end

  def add_get_request(destinations)
    [*destinations].each{ |dest| @queue.push(Message.new(:get, dest))}
  end

  def add_post_request(destinations, body)
    b = CGI::escape( body )
    [*destinations].each{|dest| @queue.push(Message.new(:post, dest, :body => b))}
  end

  def add_hub_notification(hub_url, feed_url)
    @queue.push(Message.new(:hub_publish, hub_url, :body => feed_url))
  end

  def process
    @queue.pop{ |query|
      case query.type
      when :post
        http = EventMachine::HttpRequest.new(query.destination).post :timeout => TIMEOUT, :body =>{:xml => query.body}
        http.callback { process; process}
      when :get
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {process}
      when :hub_publish
        http = EventMachine::PubSubHubbub.new(query.destination).publish :timeout => TIMEOUT
        http.callback {process}
      else
        raise "message is not a type I know!"
      end

      http.errback {
        Rails.logger.info(http.response)
        Rails.logger.info("Failure from #{query.destination}, retrying...")

        query.try_count +=1
        @queue.push query unless query.try_count >= NUM_TRIES
        process
      }
    } unless @queue.size == 0
  end

  def size
    @queue.size
  end

  class Message
    attr_accessor :type, :destination, :body, :callback, :owner_url, :try_count
    def initialize(type, dest, opts = {})
      @type = type
      @owner_url = opts[:owner_url]
      @destination = dest
      @body = opts[:body]
      @callback = opts[:callback] ||= lambda{ process; process }
      @try_count = 0
    end
  end
end

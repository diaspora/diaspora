class MessageHandler 

  
  NUM_TRIES = 3
  TIMEOUT = 5 #seconds
  
  def initialize
    @queue = EM::Queue.new
  end

  def add_get_request(destinations)
    [*destinations].each{ |dest| @queue.push(Message.new(:get, dest))}
  end

  def add_subscription_request(feed_url)
    @queue.push(Message.new(:ostatus_subscribe, feed_url)) 
  end

  def add_post_request(destinations, body)
    b = CGI::escape( body )
    [*destinations].each{|dest| @queue.push(Message.new(:post, dest, :body => b))}
  end

  # pubsubhubbub
  def add_hub_notification(hub_url, feed_url)
    @queue.push(Message.new(:hub_publish, hub_url, :body => feed_url))
  end

  def add_hub_subscription_request(hub_url, feed_url)
    @queue.push(Message.new(:hub_subscribe, hub_url, :body => feed_url))
  end

  def add_hub_unsubscribe_request(hub, from, feed_url)
    @queue.push(Message.new(:hub_unsubscribe, hub, :body => feed_url, :owner_url => from))
  end

  def process_ostatus_subscription(query_object, http)
      hub = Diaspora::OStatusParser::find_hub(http.response)
      add_hub_subscription_request(hub, query_object.destination)
      Diaspora::OStatusParser::process(http.response)
  end


  def process
    @queue.pop{ |query|
      case query.type
      when :post
        http = EventMachine::HttpRequest.new(query.destination).post :timeout => TIMEOUT, :body =>{:xml => query.body}
        http.callback { puts query.destination; puts query.body; process; process}
      when :get
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {send_to_seed(query, http.response); process}

      when :ostatus_subscribe
        puts query.destination
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback { process_ostatus_subscription(query, http); process}
        
      when :hub_publish
        http = EventMachine::PubSubHubbub.new(query.destination).publish query.body, :timeout => TIMEOUT 
        http.callback { process}

      when :hub_subscribe
        http = EventMachine::PubSubHubbub.new(query.destination).subscribe query.body, User.owner.url + 'hubbub',  :timeout => TIMEOUT 
        http.callback { process}
      when :hub_unsubscribe
        http = EventMachine::PubSubHubbub.new(query.destination).unsubscribe query.body, query.owner_url,  :timeout => TIMEOUT 
        http.callback {process}
      else
        raise "message is not a type I know!"
      end

      http.errback {
        puts http.response
        puts "failure from #{query.destination}, retrying"
        query.try_count +=1
        @queue.push query unless query.try_count >= NUM_TRIES 
        process
      }
    } unless @queue.size == 0
  end
  
  def send_to_seed(message, http_response)
    #DO SOMETHING!
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

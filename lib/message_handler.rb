class MessageHandler 
  
  include Diaspora::OStatusParser
  NUM_TRIES = 3
  TIMEOUT = 5 #seconds
  
  def initialize
    @queue = EM::Queue.new
  end

  def add_get_request(destinations)
    destinations.each{ |dest| @queue.push(Message.new(:get, dest))}
  end


  def add_post_request(destinations, body)
    b = CGI::escape( body )
    destinations.each{|dest| @queue.push(Message.new(:post, dest, :body => b))}
  end

  def add_hub_notification(destination, feed_location)
    @queue.push(Message.new(:pubhub, destination, :body => feed_location))
  end

  def add_hub_subscription_request(hub, body)
    @queue.push(Message.new(:pubhubsub, hub, :body => body))
  end

  def add_subscription_request(feed)
    @queue.push(Message.new(:subscribe, feed)) 
  end

  def process
    @queue.pop{ |query|
      case query.type
      when :post
        http = EventMachine::HttpRequest.new(query.destination).post :timeout => TIMEOUT, :body =>{:xml => query.body}
        http.callback { puts  query.destination; process; process}
      when :get
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {send_to_seed(query, http.response); process}

      when :subscribe
        puts query.destination
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {
                    require 'lib/common'
                    puts http.response
                    hub = Nokogiri::HTML(http.response).xpath('//link[@rel="hub"]').first.attribute("href").value
                    
                    add_hub_subscription_request(hub, query.destination)
                    #Diaspora::OStatus::parse_sender(http.response)
                    
                    process
          }
        
      when :pubhub
        http = EventMachine::PubSubHubbub.new(query.destination).publish query.body, :timeout => TIMEOUT 
        http.callback { process}

      when :pubhubsub
        http = EventMachine::PubSubHubbub.new(query.destination).subscribe query.body, User.owner.url,  :timeout => TIMEOUT 
        http.callback { process}
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
    attr_accessor :type, :destination, :body, :try_count
    def initialize(type, dest, opts = {})
      @type = type
      @destination = dest
      @body = opts[:body]

      opts[:callback] ||= lambda{ process; process }
      
      @callback = opts[:callback]
      @try_count = 0
    end
  end
end

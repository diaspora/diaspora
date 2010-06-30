class MessageHandler 

  NUM_TRIES = 3
  TIMEOUT = 5 #seconds

  def initialize
    @queue = EM::Queue.new
  end

  def add_get_request(destinations)
    destinations.each{ |dest| @queue.push(Message.new(:get, dest))}
  end


  def add_post_request(destinations, body)
    destinations.each{|dest| @queue.push(Message.new(:post, dest, body))}
  end

  def process
    @queue.pop{ |query|
      case query.type
      when :post
        http = EventMachine::HttpRequest.new(query.destination).post :timeout => TIMEOUT, :body =>{:xml =>  query.body}
        http.callback {process}
      when :get
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {send_to_seed(query, http.response); process}
      else
        raise "message is not a type I know!"
      end

      http.errback {
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
    def initialize(type, dest, body= nil)
      @type = type
      @destination = dest
      @body = body
      @try_count = 0
    end
  end
end

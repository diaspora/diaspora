#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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

  def process
    @queue.pop{ |query|
      case query.type
      when :post
        http = EventMachine::HttpRequest.new(query.destination).post :timeout => TIMEOUT, :body =>{:xml => query.body}
        http.callback { process; process}
      when :get
        http = EventMachine::HttpRequest.new(query.destination).get :timeout => TIMEOUT
        http.callback {send_to_seed(query, http.response); process}
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

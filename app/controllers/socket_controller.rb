class SocketController < ApplicationController 

  def incoming(msg)
    puts msg
  end
  
  
  def new_subscriber
    WebSocket.subscribe
  end
  
  
  
  def outgoing(object)
    puts "made it sucka"
    WebSocket.push_to_clients(action_hash(object))
  end
  
  
  def delete_subscriber(sid)
    WebSocket.unsubscribe(sid)
  end
  
  
# need a data strucutre to keep track of who is where

#the way this is set up now, we have users on pages

#could have... a channel for every page/collection...not that cool
#or, have a single channel, which has a corresponding :current page => [sid]
# can i cherry pick subscribers from a a channel?


# we want all sorts of stuff that comes with being a controller
# like, protect from forgery, view rendering, etc


#these functions are not really routes
#so the question is, whats the best way to call them?

#also, this is an input output controller

end

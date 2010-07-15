
require 'config/environment'

Request.all.each{|r| 
  User.owner.accept_friend_request(r.id)
}

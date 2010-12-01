# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.


# A modification proposed by Sean Treadway that increases the default accept
# queue of TCPServer to 1024 so that it handles more concurrent requests.
class TCPServer
   def initialize_with_backlog(*args)
     initialize_without_backlog(*args)
     listen(1024)
   end

   alias_method :initialize_without_backlog, :initialize
   alias_method :initialize, :initialize_with_backlog
end

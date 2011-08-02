# Copyright 2008 David Vollbracht & Philippe Hanrigou

require 'rubygems'
require 'timeout'

module SystemTimer 
 class << self

   def timeout_after(seconds)
     Timeout::timeout(seconds) do
       yield
     end
   end

   # Backward compatibility with timeout.rb
   alias timeout timeout_after 
   
 end
 
end

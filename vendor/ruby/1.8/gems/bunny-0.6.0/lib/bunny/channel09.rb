module Bunny
	class Channel09 < Qrack::Channel
		
		def initialize(client)
			super
		end
		
		def open
			client.channel = self
			client.send_frame(Qrack::Protocol09::Channel::Open.new)
			
      method = client.next_method
			
			client.check_response(method, Qrack::Protocol09::Channel::OpenOk, "Cannot open channel #{number}")

			@active = true
			:open_ok
		end
		
		def close
			client.channel = self
			client.send_frame(
	      Qrack::Protocol09::Channel::Close.new(:reply_code => 200, :reply_text => 'bye', :method_id => 0, :class_id => 0)
	    )
	
	    method = client.next_method
			
			client.check_response(method, Qrack::Protocol09::Channel::CloseOk, "Error closing channel #{number}")
	
			@active = false
			:close_ok
		end
		
		def open?
			active
		end
		
	end
end
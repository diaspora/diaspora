module Qrack
	
	# Queue ancestor class
	class Queue
		
		attr_reader :name, :client
	  attr_accessor :delivery_tag, :subscription
	
=begin rdoc

=== DESCRIPTION:

Returns consumer count from Queue#status.

=end

	  def consumer_count
	    s = status
			s[:consumer_count]
	  end

=begin rdoc

=== DESCRIPTION:

Returns message count from Queue#status.

=end

	  def message_count
	    s = status
			s[:message_count]
	  end

=begin rdoc

=== DESCRIPTION:

Publishes a message to the queue via the default nameless '' direct exchange.

==== RETURNS:

nil

=end

	  def publish(data, opts = {})
	    exchange.publish(data, opts)
	  end
		
	end
	
end

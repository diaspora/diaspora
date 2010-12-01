module Qrack
	# Subscription ancestor class
	class Subscription
		
		attr_accessor :consumer_tag, :delivery_tag, :message_max, :timeout, :ack, :exclusive
		attr_reader :client, :queue, :message_count
	
		def initialize(client, queue, opts = {})
			@client = client
			@queue = queue
		
			# Get timeout value
			@timeout = opts[:timeout] || nil
		
			# Get maximum amount of messages to process
			@message_max = opts[:message_max] || nil

			# If a consumer tag is not passed in the server will generate one
			@consumer_tag = opts[:consumer_tag] || nil

			# Ignore the :nowait option if passed, otherwise program will hang waiting for a
			# response from the server causing an error.
			opts.delete(:nowait)

			# Do we want to have to provide an acknowledgement?
			@ack = opts[:ack] || nil
			
			# Does this consumer want exclusive use of the queue?
			@exclusive = opts[:exclusive] || false
		
			# Initialize message counter
			@message_count = 0
			
			# Give queue reference to this subscription
			@queue.subscription = self
			
			# Store options
			@opts = opts
		
		end
		
		def start(&blk)
			
			# Do not process any messages if zero message_max
			if message_max == 0
				return
			end
			
			# Notify server about new consumer
			setup_consumer

			# Start subscription loop
			loop do
			
				begin
					method = client.next_method(:timeout => timeout)
				rescue Qrack::ClientTimeout
					queue.unsubscribe()
					break
				end
				
				# Increment message counter
				@message_count += 1
		
				# get delivery tag to use for acknowledge
				queue.delivery_tag = method.delivery_tag if @ack
		
				header = client.next_payload

			  # If maximum frame size is smaller than message payload body then message
				# will have a message header and several message bodies				
			  msg = ''
				while msg.length < header.size
					msg += client.next_payload
				end

				# If block present, pass the message info to the block for processing		
				blk.call({:header => header, :payload => msg, :delivery_details => method.arguments}) if !blk.nil?

				# Exit loop if message_max condition met
				if (!message_max.nil? and message_count == message_max)
					# Stop consuming messages
					queue.unsubscribe()				
					# Acknowledge receipt of the final message
					queue.ack() if @ack
					# Quit the loop
					break
				end
			
				# Have to do the ack here because the ack triggers the release of messages from the server
				# if you are using Client#qos prefetch and you will get extra messages sent through before
				# the unsubscribe takes effect to stop messages being sent to this consumer unless the ack is
				# deferred.
				queue.ack() if @ack
		
			end
		
		end
		
	end
	
end
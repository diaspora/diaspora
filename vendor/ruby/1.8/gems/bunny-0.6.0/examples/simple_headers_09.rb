# simple_headers_09.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new(:spec => '09')

# start a communication session with the amqp server
b.start

# declare queues
q = b.queue('header_q1')

# create a headers exchange
header_exch = b.exchange('header_exch', :type => :headers)

# bind the queue to the exchange
q.bind(header_exch, :arguments => {'h1'=>'a','x-match'=>'all'})

# publish messages to the exchange
header_exch.publish('Headers test msg 1', :headers => {'h1'=>'a'})
header_exch.publish('Headers test msg 2', :headers => {'h1'=>'z'})


# get messages from the queue - should only be msg 1 that got through
msg = ""
until msg == :queue_empty do
	msg = q.pop[:payload]
	puts 'This is a message from the header_q1 queue: ' + msg + "\n" unless msg == :queue_empty
end

# close the client connection
b.stop
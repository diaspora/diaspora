# simple_consumer_09.rb

# N.B. To be used in conjunction with simple_publisher.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

# How this example works
#=======================
#
# Open up two console windows start this program in one of them by typing -
#
# ruby simple_consumer_09.rb
#
# Then switch to the other console window and type -
#
# ruby simple_publisher_09.rb
#
# A message will be printed out by the simple_consumer and it will wait for the next message
# until the timeout interval is reached.
#
# Run simple_publisher as many times as you like. When you want the program to stop just stop
# sending messages and the subscribe loop will timeout after 30 seconds, the program will
# unsubscribe from the queue and close the connection to the server.

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new(:logging => true, :spec => '09')

# start a communication session with the amqp server
b.start

# create/get queue
q = b.queue('po_box')

# create/get exchange
exch = b.exchange('sorting_room')

# bind queue to exchange
q.bind(exch, :key => 'fred')

# subscribe to queue
q.subscribe(:consumer_tag => 'testtag1', :timeout => 30) do |msg|
	puts "#{q.subscription.message_count}: #{msg[:payload]}"
end

# Close client
b.stop
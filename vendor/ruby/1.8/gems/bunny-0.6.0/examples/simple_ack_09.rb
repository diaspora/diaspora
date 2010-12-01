# simple_ack_09.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new(:logging => true, :spec => '09')

# start a communication session with the amqp server
b.start

# declare a queue
q = b.queue('test1')

# publish a message to the queue
q.publish('Testing acknowledgements')

# get message from the queue
msg = q.pop(:ack => true)[:payload]

# acknowledge receipt of message
q.ack

puts 'This is the message: ' + msg + "\n\n"

# close the client connection
b.stop
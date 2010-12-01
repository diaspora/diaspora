# simple_fanout_08.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new(:logging => true)

# start a communication session with the amqp server
b.start

# declare queues
q1 = b.queue('test_fan1')
q2 = b.queue('test_fan2')

# create a fanout exchange
exch = b.exchange('test_fan', :type => :fanout)

# bind the queues to the exchange
q1.bind(exch)
q2.bind(exch)

# publish a message to the exchange
exch.publish('This message will be fanned out')

# get message from the queues
msg = q1.pop[:payload]
puts 'This is the message from q1: ' + msg + "\n\n"
msg = q2.pop[:payload]
puts 'This is the message from q2: ' + msg + "\n\n"

# close the client connection
b.stop
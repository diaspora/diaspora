# encoding: utf-8

# simple_publisher.rb

# N.B. To be used in conjunction with simple_consumer.rb. See simple_consumer.rb for explanation.

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new(:logging => true, :spec => '09')

# start a communication session with the amqp server
b.start

# create/get exchange
exch = b.exchange('sorting_room')

# publish message to exchange
exch.publish('This is a message from the publisher', :key => 'fred')

# message should now be picked up by the consumer so we can stop
b.stop

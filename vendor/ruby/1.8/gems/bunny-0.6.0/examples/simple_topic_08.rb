# simple_topic_08.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'bunny'

b = Bunny.new

# start a communication session with the amqp server
b.start

# declare queues
soccer = b.queue('topic_soccer')
cricket = b.queue('topic_cricket')
rugby = b.queue('topic_rugby')
allsport = b.queue('topic_allsport')

# create a topic exchange
sports_results = b.exchange('sports_results', :type => :topic)

# bind the queues to the exchange
soccer.bind(sports_results, :key => 'soccer.*')
cricket.bind(sports_results, :key => 'cricket.*')
rugby.bind(sports_results, :key => 'rugby.*')
allsport.bind(sports_results, :key => '*.result')

# publish messages to the exchange
sports_results.publish('Manchester United 1 : Hull City 4', :key => 'soccer.result')
sports_results.publish('England beat Australia by 5 wickets in first test', :key => 'cricket.result')
sports_results.publish('British Lions 15 : South Africa 12', :key => 'rugby.result')

# get message from the queues

# soccer queue got the soccer message
msg = soccer.pop[:payload]
puts 'This is a message from the soccer q: ' + msg + "\n\n"

# cricket queue got the cricket message
msg = cricket.pop[:payload]
puts 'This is a message from the cricket q: ' + msg + "\n\n"

# rugby queue got the rugby message
msg = rugby.pop[:payload]
puts 'This is a message from the rugby q: ' + msg + "\n\n"

# allsport queue got all of the messages
until msg == :queue_empty do
	msg = allsport.pop[:payload]
	puts 'This is a message from the allsport q: ' + msg + "\n\n" unless msg == :queue_empty
end

# close the client connection
b.stop
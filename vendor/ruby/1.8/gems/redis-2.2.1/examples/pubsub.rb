require "redis"

puts <<-EOS
To play with this example use redis-cli from another terminal, like this:

  $ redis-cli publish one hello

Finally force the example to exit sending the 'exit' message with:

  $ redis-cli publish two exit

EOS

redis = Redis.connect

trap(:INT) { puts; exit }

redis.subscribe(:one, :two) do |on|
  on.subscribe do |channel, subscriptions|
    puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
  end

  on.message do |channel, message|
    puts "##{channel}: #{message}"
    redis.unsubscribe if message == "exit"
  end

  on.unsubscribe do |channel, subscriptions|
    puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
require 'pp'

puts 'User', '*'*50
pp Twitter.user('jnunemaker')
pp Twitter.user('snitch_test')

puts 'Status', '*'*50
pp Twitter.status(1533815199)

puts 'Friend Ids', '*'*50
pp Twitter.friend_ids('jnunemaker')

puts 'Follower Ids', '*'*50
pp Twitter.follower_ids('jnunemaker')


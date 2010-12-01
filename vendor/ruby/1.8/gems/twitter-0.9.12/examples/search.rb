require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
require 'pp'

search = Twitter::Search.new.from('jnunemaker')

puts '*'*50, 'First Run', '*'*50
search.each { |result| pp result }

puts '*'*50, 'Second Run', '*'*50
search.each { |result| pp result }

puts '*'*50, 'Parameter Check', '*'*50
pp Twitter::Search.new('#austineats').fetch().results.first
pp Twitter::Search.new('#austineats').page(2).fetch().results.first
pp Twitter::Search.new('#austineats').since(1412737343).fetch().results.first

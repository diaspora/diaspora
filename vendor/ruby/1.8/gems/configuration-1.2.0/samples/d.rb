#
# configuration.rb makes use of an external blank slate dsl, this means that
# you Configuration objects do, in fact, have all built-in ruby methods such
# as #inspect, etc, *unless* you configure over the top of them.  the effect
# is a configuration object that behaves like a nice ruby object, but which
# allows *any* key to be configured
#
  require 'configuration'

  c = Configuration.for 'd' 

  p c.object_id
  p c.inspect
  p c.p

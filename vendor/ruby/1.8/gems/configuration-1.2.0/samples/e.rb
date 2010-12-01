#
# configuration.rb uses a totally clean slate dsl for the block.  if you need
# to access base Object methods you can do this
#

  require 'configuration'

  c = Configuration.for 'e'

  p c.foo
  p c.bar
  p c.foobar

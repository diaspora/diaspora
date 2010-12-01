#
# configuration.rb supports a very natural nesting syntax.  note how values
# are scoped in a POLS fashion
#
  require 'configuration'

  c = Configuration.for 'b' 

  p c.www.url
  p c.db.url
  p c.mail.url

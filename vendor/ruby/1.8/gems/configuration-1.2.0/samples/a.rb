#
# basic usage is quite, simple, load the config and use it's values.  the
# config syntax is fairly obvious, i think, but note that it *is* ruby and any
# ruby can be included.  also note that each config is named, allowing
# multiple configs to be places in one file 
#
  require 'configuration'
 
  c = Configuration.load 'a'

  p c.a + c.b - c.c

#
# the cwd can be supplied
#
  require 'systemu'
  require 'tmpdir'

  pwd = %q( ruby -e"  STDERR.puts Dir.pwd  " )

  status = systemu pwd, 2=>(stderr=''), :cwd=>Dir.tmpdir
  puts stderr


#
# any environment vars specified are merged into the child's environment
#
  require 'systemu'

  env = %q( ruby -r yaml -e"  puts ENV[ 'answer' ] " )

  status = systemu env, 1=>stdout='', 'env'=>{ 'answer' => 0b101010 }
  puts stdout

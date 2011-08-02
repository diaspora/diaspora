#
# quite a few keys can be passed to the command to alter it's behaviour.  if
# either stdout or stderr is supplied those objects should respond_to? '<<'
# and only status will be returned
#
  require 'systemu'

  date = %q( ruby -e"  t = Time.now; STDOUT.puts t; STDERR.puts t  " )

  stdout, stderr = '', ''
  status = systemu date, 'stdout' => stdout, 'stderr' => stderr
  p [ status, stdout, stderr ]

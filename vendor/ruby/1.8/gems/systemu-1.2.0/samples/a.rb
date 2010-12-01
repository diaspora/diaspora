#
# systemu can be used on any platform to return status, stdout, and stderr of
# any command.  unlike other methods like open3/popen4 there is zero danger of
# full pipes or threading issues hanging your process or subprocess.
#
  require 'systemu'

  date = %q( ruby -e"  t = Time.now; STDOUT.puts t; STDERR.puts t  " )

  status, stdout, stderr = systemu date
  p [ status, stdout, stderr ]

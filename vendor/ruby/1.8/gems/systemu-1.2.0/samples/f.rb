#
# if a block is specified then it is passed the child pid and run in a
# background thread.  note that this thread will __not__ be blocked during the
# execution of the command so it may do useful work such as killing the child
# if execution time passes a certain threshold
#
  require 'systemu'

  looper = %q( ruby -e" loop{ STDERR.puts Time.now.to_i; sleep 1 } " )

  status, stdout, stderr =
    systemu looper do |cid|
      sleep 3
      Process.kill 9, cid
    end

  p status
  p stderr

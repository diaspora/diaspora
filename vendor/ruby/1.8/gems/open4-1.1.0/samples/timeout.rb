
require 'open4'

def show_failure
  fork{ yield }
  Process.wait
  puts
end

#
# command timeout
#
  show_failure{
    open4.spawn 'sleep 42', 'timeout' => 1
  }

#
# stdin timeout
#
  show_failure{

    producer = 'ruby -e" STDOUT.sync = true; loop{sleep(rand+rand) and puts 42} " 2>/dev/null'

    consumer = 'ruby -e" STDOUT.sync = true; STDIN.each{|line| puts line} "'

    open4(producer) do |pid, i, o, e|
      open4.spawn consumer, 0=>o, 1=>STDOUT, :stdin_timeout => 1.4
    end
  }

#
# stdout timeout (stderr is similar)
#

  show_failure{
    open4.spawn 'ruby -e"  sleep 2 and puts 42  "', 'stdout_timeout' => 1
  }

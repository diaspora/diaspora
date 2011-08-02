require 'open4'

producer = 'ruby -e" STDOUT.sync = true; loop{sleep(rand+rand) and puts 42} " 2>/dev/null'

consumer = 'ruby -e" STDOUT.sync = true; STDIN.each{|line| puts line} "'

open4(producer) do |pid, i, o, e|
  open4.spawn consumer, 0=>o, 1=>STDOUT, :stdin_timeout => 1.4
end

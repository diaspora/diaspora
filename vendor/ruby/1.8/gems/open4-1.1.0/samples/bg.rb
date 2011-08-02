require 'yaml'
require 'open4'
include Open4

stdin = '42'
stdout = ''
stderr = ''

t = bg 'ruby -e"sleep 4; puts ARGF.read"', 0=>stdin, 1=>stdout, 2=>stderr

waiter = Thread.new{ y t.pid => t.exitstatus } # t.exitstatus is a blocking call!

while((status = t.status))
  y "status" => status
  sleep 1
end

waiter.join

y "stdout" => stdout


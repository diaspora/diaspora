require 'thread'

def tail_lines(io)
  io.each_line { |line| yield line }
  if io.eof? then
    sleep 0.25
    io.pos = io.pos # reset eof?
    retry
  end
end

count = 0
mutex = Mutex.new

Thread.start do
  loop do
    sleep 1
    mutex.synchronize do
      puts count
      count = 0
    end
  end
end

pattern = Regexp.new(ARGV.first)
tail_lines(STDIN) do |line|
  next unless line =~ pattern
  mutex.synchronize { count += 1 }
end
